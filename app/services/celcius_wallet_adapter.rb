# frozen_string_literal: true

class CelciusWalletAdapter
  include FetchExchangeHistory

  def initialize(account)
    @account = account
    @base_url = 'https://wallet-api.celsius.network'
  end

  def verify_credentials
    res = api_service.call('/kyc', request_headers)

    raise ThirdPartyAuthenticationError::InvalidApiKey if res[:slug] == 'INVALID_API_KEY'

    true
  end

  def update_history
    fetch_history
  end

  def fetch_history
    fetch('assets', '/wallet/balance', request_headers)
    fetch('transactions', '/wallet/transactions?page=1&per_page=100', request_headers, pagination_options)
  end

  private

  def request_headers
    proc do
      {
        'X-Cel-Partner-Token': ENV['celcius_wallet_api_key'],
        'X-Cel-Api-Key': @account.api_key
      }
    end
  end

  def pagination_options
    {
      data_key: :record,
      more_data_condition: ->(res) { res[:pagination] && res[:pagination][:pages] > res[:pagination][:current] },
      new_path: ->(res) { "/wallet/transactions?page=#{res[:pagination][:current] + 1}&per_page=100" }
    }
  end

  def parse_assets(api_data:)
    api_data[:balance].keys.map do |key|
      currency = key.to_s.upcase

      {
        remote_id: currency,
        currency: currency,
        current_balance: api_data[:balance][key]
      }
    end.compact
  end

  def parse_transactions(api_data:)
    api_data.map do |data|
      return nil unless data[:state] == 'confirmed'

      if data[:nature] == 'interest'
        {
          remote_id: data[:id],
          details: nil,
          currency: data[:coin],
          entry_type: data[:nature],
          amount: data[:amount]&.to_f,
          total_price: data[:amount_usd]&.to_f,
          occurred_at: data[:time]
        }
      elsif %w[referred_award referrer_award promo_code_reward].include?(data[:nature])
        {
          remote_id: data[:id],
          details: data[:nature].gsub(/\_/, ' '),
          currency: data[:coin],
          entry_type: 'free',
          amount: data[:amount]&.to_f,
          total_price: data[:amount_usd]&.to_f,
          occurred_at: data[:time]
        }
      elsif data[:nature] == 'deposit'
        {
          remote_id: data[:id],
          details: 'to Celcius',
          currency: data[:coin],
          entry_type: 'transfer',
          amount: data[:amount]&.to_f,
          total_price: data[:amount_usd]&.to_f,
          occurred_at: data[:time]
        }
      else
        p data

        nil
      end
    end.compact
  end
end
