# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/v1/users' do
  include_context 'new user'

  let(:path) { api_v1_users_path }

  include_examples 'a client ID protected endpoint'

  context 'with email and password in params and client ID in headers' do
    before do
      expect(User.all.length).to eq(0)

      post path, params: params, headers: headers
    end

    it 'creates a user' do
      expect(User.all.length).to eq(1)
    end

    it 'responds with a 201' do
      expect(response.status).to eq(201)
    end

    it 'responds with the correct user in a JWT' do
      created_user = User.all.first
      decoded_token = JsonWebToken.decode(token: json_response[:token])

      expect(decoded_token[0]['user_id']).to eq(created_user[:id])
    end
  end

  context 'when a user already exists with the new email' do
    let(:user)   { create(:user) }
    let(:params) { { email: user.email, password: 'anything' } }

    it 'responds with a 422' do
      post path, params: params, headers: headers

      expected_error(status: 422, message: 'Validation failed: Email has already been taken')
    end
  end
end
