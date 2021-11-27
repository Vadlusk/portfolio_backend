# frozen_string_literal: true

ActionDispatch::Request.parameter_parsers[:json] = lambda do |raw_post|
  data = ActiveSupport::JSON.decode(raw_post)

  if data.is_a?(Array)
    data.map { |item| item.deep_transform_keys!(&:underscore) }
  else
    data.deep_transform_keys!(&:underscore)
  end

  data.is_a?(Hash) ? data : { '_json': data }
end
