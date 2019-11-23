def json_response
  @json_response ||= JSON.parse(response.body, symbolize_names: true)
end

def expected_error(status:, message:)
  expect(response.status).to eq(status)
  expect(json_response[:error]).to eq(message)
end
