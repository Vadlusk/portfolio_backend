# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/accounts' do
  include_context 'authenticated user'

  let(:path) { api_v1_accounts_path }

  include_examples 'a JWT protected endpoint', :get

  context 'with valid credentials' do
    before(:each) do
      create(:account, user_id: user.id)
      create(:account)

      get path, headers: headers
    end

    it 'responds with a 200' do
      expect(response.status).to eq(200)
    end

    it 'returns all accounts for a user' do
      expect(Account.all.length).to eq(2)
      expect(json_response[:accounts].length).to eq(1)
      expect(json_response[:accounts][0].keys).to contain_exactly(*ACCOUNT_ATTRS)
    end

    it_behaves_like 'it returns a new jwt'
  end
end
