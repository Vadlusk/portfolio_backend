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
        free_coin_transaction(data, 'Coinbase earn')
      elsif data[:type] == 'staking_reward'
        free_coin_transaction(data, 'staking reward')
      elsif data[:type] == 'send' && data[:description] == 'R7 - US Debit Card Rewards (external funded)'
        free_coin_transaction(data, 'debit card reward')
      elsif data[:type] == 'buy'
        {
          remote_id: data[:id],
          entry_type: 'buy',
          details: nil,
          currency: "#{data[:amount][:currency]}-#{data[:native_amount][:currency]}",
          amount: data[:amount][:amount].to_f.abs,
          price_per_coin: data[:native_amount][:amount].to_f.abs / data[:amount][:amount].to_f.abs,
          total_price: data[:native_amount][:amount].to_f.abs,
          occurred_at: data[:created_at]
        }
      elsif data[:type] == 'sell'
        {
          remote_id: data[:id],
          entry_type: 'sell',
          details: nil,
          currency: "#{data[:amount][:currency]}-#{data[:native_amount][:currency]}",
          amount: data[:amount][:amount].to_f.abs,
          price_per_coin: data[:native_amount][:amount].to_f.abs / data[:amount][:amount].to_f.abs,
          total_price: data[:native_amount][:amount].to_f.abs,
          occurred_at: data[:created_at]
        }
      elsif data[:type] == 'trade'
        {
          remote_id: data[:id],
          entry_type: data[:amount][:amount].to_f.positive? ? 'buy' : 'sell',
          details: 'conversion',
          currency: data[:amount][:currency],
          amount: data[:amount][:amount].to_f.abs,
          price_per_coin: data[:native_amount][:amount].to_f.abs / data[:amount][:amount].to_f.abs,
          total_price: data[:native_amount][:amount].to_f.abs,
          occurred_at: data[:created_at]
        }
      elsif data[:type] == 'pro_withdrawal'
        transfer(data, 'from Coinbase Pro to Coinbase')
      elsif data[:type] == 'pro_deposit' || (data[:type] == 'exchange_deposit' && data[:details][:subtitle] == 'To Coinbase Pro')
        transfer(data, 'from Coinbase to Coinbase Pro')
      elsif data[:type] == 'send' && data[:description] != 'R7 - US Debit Card Rewards (external funded)' && data[:description] != 'Earn Task' && data[:details][:subtitle] != 'From Coinbase Earn'
        transfer(data, "from Coinbase t#{data[:details][:subtitle][1..-1]}")
      elsif data[:type] == 'interest'
        {
          remote_id: data[:id],
          entry_type: 'interest',
          details: nil,
          currency: data[:amount][:currency],
          amount: data[:amount][:amount].to_f.abs,
          price_per_coin: data[:native_amount][:amount].to_f / data[:amount][:amount].to_f,
          total_price: data[:native_amount][:amount].to_f,
          occurred_at: data[:created_at]
        }
      else
        p data

        nil
      end
    end.compact
  end

  def free_coin_transaction(raw_transaction, reason)
    {
      remote_id: raw_transaction[:id],
      entry_type: 'free',
      details: reason,
      currency: raw_transaction[:amount][:currency],
      amount: raw_transaction[:amount][:amount].to_f.abs,
      price_per_coin: raw_transaction[:native_amount][:amount].to_f.abs / raw_transaction[:amount][:amount].to_f.abs,
      total_price: raw_transaction[:native_amount][:amount].to_f.abs,
      occurred_at: raw_transaction[:created_at]
    }
  end

  def transfer(raw_transaction, from_to)
    {
      remote_id: raw_transaction[:id],
      entry_type: 'transfer',
      details: from_to,
      currency: raw_transaction[:amount][:currency],
      amount: raw_transaction[:amount][:amount].to_f.abs,
      price_per_coin: nil,
      total_price: nil,
      occurred_at: raw_transaction[:created_at]
    }
  end
end
