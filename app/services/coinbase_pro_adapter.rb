# frozen_string_literal: true

class CoinbaseProAdapter
  include FetchExchangeHistory

  def initialize(account)
    @account = account
    @base_url = 'https://api.pro.coinbase.com'
  end

  def verify_credentials
    res = api_service.call('/accounts', headers)

    if res.is_a?(Hash)
      raise ThirdPartyAuthenticationError::InvalidApiKey if res[:message] == 'Invalid API Key'
      raise ThirdPartyAuthenticationError::InvalidSecret if res[:message] == 'invalid signature'
      raise ThirdPartyAuthenticationError::InvalidPassphrase if res[:message] == 'Invalid Passphrase'
    end

    true
  end

  def update_history
    fetch_history
  end

  def fetch_history
    fetch('assets', '/accounts', headers)
    fetch('transactions', '/orders?status=done', headers)
    fetch('transactions', '/transfers', headers)
  end

  private

  def headers
    proc do |path|
      timestamp = Time.now.to_i
      signature = Base64.strict_encode64(
        OpenSSL::HMAC.digest(
          'sha256',
          Base64.decode64(@account.secret),
          "#{timestamp}GET#{path}"
        )
      )

      {
        'CB-ACCESS-KEY': @account.api_key,
        'CB-ACCESS-TIMESTAMP': timestamp.to_s,
        'CB-ACCESS-PASSPHRASE': @account.passphrase,
        'CB-ACCESS-SIGN': signature
      }
    end
  end

  def parse_assets(api_data:)
    api_data.map do |data|
      {
        remote_id: data[:id],
        currency: data[:currency],
        current_balance: data[:balance]&.to_f
      }
    end
  end

  def parse_transactions(api_data:)
    api_data.map do |data|
      if data[:type] == 'withdraw'
        sent_to = data[:details][:sent_to_address] ? data[:details][:sent_to_address] : 'Coinbase'
        asset = Asset.where(remote_id: data[:details][:coinbase_account_id])[0]
        currency = asset ? asset[:currency] : ''

        {
          remote_id: data[:id],
          entry_type: 'transfer',
          details: "from Coinbase Pro to #{sent_to}",
          currency: currency,
          amount: data[:amount]&.to_f,
          price_per_coin: nil,
          total_price: nil,
          fees: data[:details][:fee]&.to_f,
          occurred_at: data[:created_at]
        }
      elsif data[:type] == 'deposit'
        usd_deposit = ActiveModel::Type::Boolean.new.cast(data[:details][:is_instant_usd])
        asset = Asset.where(remote_id: data[:details][:coinbase_account_id])[0]
        currency = usd_deposit ? 'USD' : asset ? asset[:currency] : ''

        {
          remote_id: data[:id],
          entry_type: 'transfer',
          details: "from #{} to Coinbase Pro",
          currency: currency,
          amount: data[:amount]&.to_f,
          price_per_coin: nil,
          total_price: nil,
          fees: data[:details][:fee]&.to_f,
          occurred_at: data[:created_at]
        }
      elsif data[:side] == 'buy' || data[:side] == 'sell'
        unless data[:done_reason] == 'filled'
          p data
          return nil
        end

        {
          remote_id: data[:id],
          currency: data[:product_id],
          entry_type: data[:side],
          amount: data[:filled_size]&.to_f,
          fees: data[:fill_fees]&.to_f,
          price_per_coin: data[:price]&.to_f,
          total_price: data[:executed_value]&.to_f.abs,
          occurred_at: data[:done_at]
        }
      else
        p data

        nil
      end
    end.compact
  end
end
