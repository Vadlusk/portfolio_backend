# frozen_string_literal: true

class CoinbaseAdapter
  include FetchExchangeHistory

  def initialize(account)
    @account = account
    @base_url = 'https://api.coinbase.com'
  end

  def verify_credentials
    res = api_service.call('/v2/user', headers)

    if res[:errors]
      raise ThirdPartyAuthenticationError::InvalidApiKey if res[:errors].any? do |error|
                                                              error[:message] == 'invalid api key'
                                                            end
      # user secret being incorrect will make header signature incorrect
      raise ThirdPartyAuthenticationError::InvalidSecret if res[:errors].any? do |error|
                                                              error[:message] == 'invalid signature'
                                                            end
    end

    true
  end

  def update_history
    fetch_history
  end

  def fetch_history
    fetch('assets', '/v2/accounts?limit=100', headers, pagination_options)

    remote_asset_ids = @account.assets.pluck(:remote_id)

    remote_asset_ids.each do |id|
      fetch('transactions', "/v2/accounts/#{id}/transactions?limit=100", headers, pagination_options)
    end
  end

  private

  def headers
    proc do |path|
      timestamp = Time.now.to_i
      signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        @account.secret,
        "#{timestamp}GET#{path}"
      )

      {
        'CB-ACCESS-KEY': @account.api_key,
        'CB-ACCESS-TIMESTAMP': timestamp.to_s,
        'CB-VERSION': '2021-07-04',
        'CB-ACCESS-SIGN': signature
      }
    end
  end

  def pagination_options
    {
      data_key: :data,
      more_data_condition: ->(res) { res[:pagination] && !res[:pagination][:next_uri].nil? },
      new_path: ->(res) { res[:pagination] && res[:pagination][:next_uri] }
    }
  end

  def parse_assets(api_data:)
    api_data.map do |data|
      {
        remote_id: data[:id],
        currency: data[:balance][:currency],
        current_balance: data[:balance][:amount].to_f
      }
    end
  end

  def parse_transactions(api_data:)
    nil if api_data.empty?

    api_data.map do |data|
      next unless data[:status] == 'completed'
      next if data[:type] == 'cardspend' || data[:type] == 'cardbuyback'

      if data[:description] == 'Earn Task' || data[:details][:subtitle] == 'From Coinbase Earn'
        non_transfer_transaction(data, 'free', 'Coinbase earn')
      elsif data[:type] == 'staking_reward'
        non_transfer_transaction(data, 'free', 'staking reward')
      elsif data[:type] == 'send' && data[:description] == 'R7 - US Debit Card Rewards (external funded)'
        non_transfer_transaction(data, 'free', 'debit card reward')
      elsif data[:type] == 'buy'
        non_transfer_transaction(data, 'buy')
      elsif data[:type] == 'sell'
        non_transfer_transaction(data, 'sell')
      elsif data[:type] == 'trade'
        non_transfer_transaction(data, data[:amount][:amount].to_f.positive? ? 'buy' : 'sell', 'conversion')
      elsif data[:type] == 'pro_withdrawal'
        transfer(data, 'from Coinbase Pro to Coinbase')
      elsif data[:type] == 'pro_deposit' || (data[:type] == 'exchange_deposit' && data[:details][:subtitle] == 'To Coinbase Pro')
        transfer(data, 'from Coinbase to Coinbase Pro')
      elsif data[:type] == 'send' && data[:description] != 'R7 - US Debit Card Rewards (external funded)' && data[:description] != 'Earn Task' && data[:details][:subtitle] != 'From Coinbase Earn'
        transfer(data, "from Coinbase t#{data[:details][:subtitle][1..-1]}")
      elsif data[:type] == 'interest'
        non_transfer_transaction(data, 'interest')
      else
        p data

        nil
      end
    end.compact
  end

  def non_transfer_transaction(raw_transaction, entry_type, details)
    {
      entry_type: entry_type,
      details: details,
    }.merge(common_transaction_attributes(raw_transaction))
     .merge(non_transfer_attributes(raw_transaction))
  end

  def non_transfer_attributes(raw_transaction)
    {
      currency: "#{raw_transaction[:amount][:currency]}#{raw_transaction[:native_amount][:currency] ? '-' + raw_transaction[:native_amount][:currency] : ''}",
      price_per_coin: raw_transaction[:native_amount][:amount].to_f.abs / raw_transaction[:amount][:amount].to_f.abs,
      total_price: raw_transaction[:native_amount][:amount].to_f.abs
    }
  end

  def transfer(raw_transaction, details = nil)
    {
      entry_type: 'transfer',
      details: details,
      currency: raw_transaction[:amount][:currency],
      price_per_coin: nil,
      total_price: nil,
    }.merge(common_transaction_attributes(raw_transaction))
  end

  def common_transaction_attributes(raw_transaction)
    {
      remote_id: raw_transaction[:id],
      amount: raw_transaction[:amount][:amount].to_f.abs,
      occurred_at: raw_transaction[:created_at]
    }
  end
end
