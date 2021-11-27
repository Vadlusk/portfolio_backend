# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/v1/users/authenticate' do
  let(:path)     { '/api/v1/users/authenticate' }
  let(:user)     { create(:user) }
  let(:email)    { user.email }
  let(:password) { user.password }
  let(:params)   { { email: email, password: password } }
  let(:headers)  { { 'Authorization': "Token token=#{ENV['client_id']}" } }

  it_behaves_like 'a client ID protected endpoint'

  context 'with valid credentials' do
    before do
      post path, params: params, headers: headers
    end

    it 'responds with a 200' do
      expect(response.status).to eq(200)
    end

    it 'responds with the correct user id and JWT' do
      decoded_token = JsonWebToken.decode(token: json_response[:token])

      expect(json_response.keys).to include(:user_id, :token)
      expect(json_response[:user_id]).to eq(user[:id])
      expect(decoded_token[0]['user_id']).to eq(user[:id])
    end
  end

  context 'when the email does not exist in the database' do
    let(:email) { 'wrong@wrong.com' }

    it 'responds with a 404' do
      post path, params: params, headers: headers

      expected_error(status: 404, message: "Couldn't find User")
    end
  end

  context 'when the password is incorrect' do
    let(:password) { 'cant be right' }

    it 'responds with a 401' do
      post path, params: params, headers: headers

      expected_error(status: 401, message: 'Password is incorrect')
    end
  end
end
