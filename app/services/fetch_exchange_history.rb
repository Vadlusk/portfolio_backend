# frozen_string_literal: true

module FetchExchangeHistory
  def fetch(resource, path, headers, pagination_callback = nil)
    response = api_service.call(path, headers, pagination_callback)

    parsed_api_data = send(
      "parse_#{resource}".to_sym,
      api_data: response.compact
    )

    if parsed_api_data&.length&.positive?
      @account.send(resource).upsert_all(
        parsed_api_data,
        unique_by: unique_by(resource)
      )
    end
  end

  private

  def api_service
    @api_service ||= CallExchange.new({ base_url: @base_url })
  end

  def unique_by(resource)
    case resource
    when 'assets'
      %i[account_id currency]
    when 'transactions'
      %i[account_id remote_id]
    end
  end
end
