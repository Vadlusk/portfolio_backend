# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/v1/accounts' do
  let(:user)    { create(:user) }
  let(:jwt)     { JsonWebToken.encode(payload: { user_id: user.id }) }
  let(:headers) { { 'Authorization': "Basic token=#{jwt}" } }
  let(:params)  do
    {
      name: 'CoinbasePro',
      api_key: 'api_key',
      secret: 'secret',
      passphrase: 'passphrase',
      category: 'crypto_exchange'
    }
  end
  let(:path) { api_v1_accounts_path }

  it_behaves_like 'a JWT protected endpoint', :post

  context 'with valid credentials' do
    before do
      expect(Account.where(user_id: user.id, name: 'CoinbasePro').length).to eq(0)

      post path, headers: headers, params: params
    end

    it 'responds with a 201' do
      expect(response.status).to eq(201)
    end

    it 'creates an account' do
      expect(Account.where(user_id: user.id, name: 'CoinbasePro').length).to eq(1)
    end

    it 'returns the account' do
      expect(json_response[:account][:name]).to eq('CoinbasePro')
    end

    it 'returns a new jwt' do
      expect { JsonWebToken.decode(token: json_response[:token]) }.to_not raise_error
    end
  end
end
