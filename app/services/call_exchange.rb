# frozen_string_literal: true

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class CallExchange
  def initialize(base_url:)
    @connection = Faraday.new(base_url)
  end

  def call(path, headers, pagination_options = nil)
    res = JSON.parse(response(path, headers).body, symbolize_names: true)

    raise res[1][0][:id] if res.is_a?(Array) && res[1].is_a?(Array) && res[1][0][:id] == 'invalid_scope'

    pagination_options ? parse_paginated_response(res, pagination_options, headers) : res
  end

  private

  def response(path, headers)
    @connection.get(base_path(path)) do |request|
      request.params = params(path)

      headers.call(path).each_pair do |key, value|
        request.headers[key] = value
      end
    end
  end

  def base_path(path)
    if path.include?('?')
      path.split('?')[0]
    else
      path
    end
  end

  def params(path)
    if path.include?('?')
      path.split('?')[1].split('&').each_with_object({}) do |criteria, result|
        attribute, value = criteria.split('=')
        result[attribute.to_sym] = value
      end
    else
      {}
    end
  end

  def parse_paginated_response(res, options, headers)
    data_from_paginated_call = []

    data_from_paginated_call.push(res[options[:data_key]])
    call(options[:new_path].call(res), headers, options) if options[:more_data_condition].call(res)

    data_from_paginated_call.flatten
  end
end
