class CallExchange
  def initialize(api_info)
    @name       = api_info[:name]
    @api_key    = api_info[:api_key]
    @secret     = api_info[:secret]
    @passphrase = api_info[:passphrase]
    @connection = Faraday.new('https://api.pro.coinbase.com')
  end

  def assets
    JSON.parse(response('/accounts').body, symbolize_names: true)
  end

  def history(account_ids)
    account_ids.map do |account_id|
      JSON.parse(response("/accounts/#{account_id}/ledger").body, symbolize_names: true)
    end
  end

  private

    def response(path)
      @connection.get(path) do |request|
        timestamp = Time.now.to_i

        request.headers['CB-ACCESS-KEY'] = @api_key
        request.headers['CB-ACCESS-SIGN'] = coinbase_pro_signature(path, timestamp)
        request.headers['CB-ACCESS-TIMESTAMP'] = timestamp.to_s
        request.headers['CB-ACCESS-PASSPHRASE'] = @passphrase
      end
    end

    def coinbase_pro_signature(path, timestamp)
      hash = OpenSSL::HMAC.digest(
        'sha256',
        Base64.decode64(@secret),
        "#{timestamp.to_s}GET#{path}"
      )

      Base64.strict_encode64(hash)
    end
end
