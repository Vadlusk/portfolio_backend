require 'rails_helper'

describe 'POST /api/v1/users/authenticate' do
  let(:path)     { '/api/v1/users/authenticate' }
  let(:user)     { create(:user) }
  let(:email)    { user.email }
  let(:password) { user.password }
  let(:params)   { { email: email, password: password } }
  let(:headers)  { { 'Authorization': "Token token=#{ENV['client_id']}" } }

  it_behaves_like 'a client ID protected endpoint'
  it_behaves_like 'an authentication endpoint'

  context 'with valid credentials' do
    before do
      post path, params: params, headers: headers
    end

    it 'responds with a 200' do
      expect(response.status).to eq(200)
    end

    it 'responds with the correct user id and JWTs' do
      decoded_refresh_token = JsonWebToken.decode(token: json_response[:refresh_token])
      decoded_access_token = JsonWebToken.decode(token: json_response[:access_token])

      expect(json_response.keys).to include(:user_id, :refresh_token, :access_token)
      expect(json_response[:user_id]).to eq(user[:id])
      expect(decoded_refresh_token[0]['user_id']).to eq(user[:id])
      expect(decoded_access_token[0]['user_id']).to eq(user[:id])
    end
  end

  context 'when the email does not exist in the database' do
    let(:email) { 'wrong@wrong.com' }

    it 'responds with a 404 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 404, message: "Couldn't find User")
    end
  end

  context 'when the password is incorrect' do
    let(:password) { 'cant be right' }

    it 'responds with a 401 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 401, message: 'Password is incorrect')
    end
  end
end
