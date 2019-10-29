RSpec.shared_examples 'an authentication endpoint' do
  context 'without a password' do
    let!(:password) { nil }

    it 'responds with a 401 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 401, message: 'Password is required')
    end
  end

  context 'without an email' do
    let(:email) { nil }

    it 'responds with a 401 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 401, message: 'Email is required')
    end
  end
end
