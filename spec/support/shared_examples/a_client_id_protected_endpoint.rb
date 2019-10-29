RSpec.shared_examples 'a client ID protected endpoint' do
  context 'without an authorization header' do
    it 'responds with a 401 and an error message' do
      post path, params: params

      expected_error_status_and_message(status: 401, message: 'Authorization header is required')
    end
  end

  context 'with an invalid client ID' do
    let(:headers) { { 'Authorization': "Token token=not_right" } }

    it 'responds with a 401 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 401, message: 'Client ID is invalid')
    end
  end
end
