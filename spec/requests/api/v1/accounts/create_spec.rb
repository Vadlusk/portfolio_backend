# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/v1/accounts' do
  include_context 'authenticated user'

  let(:nickname) { 'nickname' }
  let(:params) do
    {
      nickname: nickname,
      assets: [{ currency: 'BTC', current_balance: 13 }]
    }
  end
  let(:path) { api_v1_accounts_path }

  include_examples 'a JWT protected endpoint', :post

  context 'with valid credentials' do
    before do
      expect(Account.where(user_id: user.id, nickname: nickname).length).to eq(0)

      post path, headers: headers, params: params
    end

    it 'creates an account' do
      expect(Account.where(user_id: user.id, nickname: nickname).length).to eq(1)
    end

    it 'responds with a 201' do
      expect(response.status).to eq(201)
    end

    it 'returns the account' do
      expect(json_response[:account][:nickname]).to eq(nickname)
    end

    it_behaves_like 'it returns a new jwt'
  end
end
