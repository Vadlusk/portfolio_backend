require 'rails_helper'

describe 'POST /api/v1/users' do
  let(:path)     { api_v1_users_path }
  let(:email)    { 'valid@mail.com' }
  let(:password) { 'password' }
  let(:params)   { { email: email, password: password } }
  let(:headers)  { { 'Authorization': "Token token=#{ENV['client_id']}" } }

  it_behaves_like 'a client ID protected endpoint'

  context 'with email and password in params and client ID in headers' do
    before do
      expect(User.all.length).to eq(0)

      post path, params: params, headers: headers
    end

    it 'creates a user' do
      expect(User.all.length).to eq(1)
    end

    it 'responds with a 201 status' do
      expect(response.status).to eq(201)
    end

    it 'responds with a user ID and a valid JWT' do
      created_user = User.all.first
      decoded_token = JsonWebToken.decode(token: json_response[:token])

      expect(json_response.keys).to include(:user_id, :token)
      expect(json_response[:user_id]).to eq(created_user[:id])
      expect(decoded_token[0]['user_id']).to eq(created_user[:id])
    end
  end

  context 'when a user already exists with the new email' do
    let(:user)   { create(:user) }
    let(:params) { { email: user.email, password: 'anything' } }

    it 'responds with a 422 and an error message' do
      post path, params: params, headers: headers

      expected_error_status_and_message(status: 422, message: 'Validation failed: Email has already been taken')
    end
  end
end
