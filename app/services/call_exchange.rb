class CallExchange
  def initialize(api_info)
    @key        = api_info[:api_key]
    @secret     = api_info[:secret]
    @passphrase = api_info[:passphrase]
    @connection = Faraday.new('https://api.pro.coinbase.com')
  end

  def assets
    JSON.parse(response('/accounts').body, symbolize_names: true)
  end

  def transfers
    JSON.parse(response('/transfers').body, symbolize_names: true)
  end

  def transactions(account_ids)
    account_ids.map do |account_id|
      JSON.parse(response("/accounts/#{account_id}/ledger").body, symbolize_names: true)
    end
  end

  def orders
    JSON.parse(response('/orders', { status: 'all' }).body, symbolize_names: true)
  end

  private

    def response(path, params = {})
      @connection.get(path) do |request|
        timestamp = Time.now.to_i

        request.params = params

        request.headers['CB-ACCESS-KEY'] = @key
        request.headers['CB-ACCESS-SIGN'] = signature(params.empty? ? path : path + '?status=all', nil, timestamp)
        request.headers['CB-ACCESS-TIMESTAMP'] = timestamp.to_s
        request.headers['CB-ACCESS-PASSPHRASE'] = @passphrase
      end
    end

    def signature(request_path = '', body = '', timestamp = nil, method = 'GET')
      body = body.to_json if body.is_a?(Hash)
      timestamp = Time.now.to_i if !timestamp

      what = "#{timestamp}#{method}#{request_path}#{body}";

      # create a sha256 hmac with the secret
      secret = Base64.decode64(@secret)
      hash  = OpenSSL::HMAC.digest('sha256', secret, what)
      Base64.strict_encode64(hash)
    end
end
