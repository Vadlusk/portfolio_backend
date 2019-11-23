shared_examples 'a client ID protected endpoint' do
  context 'without an authorization header' do
    it 'responds with a 401' do
      post path, params: params

      expected_error(status: 401, message: 'Authorization header is required')
    end
  end

  context 'with an invalid client ID' do
    let(:headers) { { 'Authorization': "Token token=not_right" } }

    it 'responds with a 401' do
      post path, params: params, headers: headers

      expected_error(status: 401, message: 'Client ID is invalid')
    end
  end

  context 'without a password' do
    let!(:password) { nil }

    it 'responds with a 401' do
      post path, params: params, headers: headers

      expected_error(status: 401, message: 'Password is required')
    end
  end

  context 'without an email' do
    let(:email) { nil }

    it 'responds with a 401' do
      post path, params: params, headers: headers

      expected_error(status: 401, message: 'Email is required')
    end
  end
end
