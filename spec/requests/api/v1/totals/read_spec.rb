# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/totals' do
  include_context 'authenticated user'

  let(:path) { api_v1_totals_path }

  include_examples 'a JWT protected endpoint', :get

  context 'with valid credentials' do
    before(:each) do
      create(:account_with_bitcoin, user: user)

      get path, headers: headers
    end

    it 'responds with a 200' do
      expect(response.status).to eq(200)
    end

    it 'returns all totals for a user' do
      expect(json_response[:totals].keys).to eq(%i[fiat_spent fiat_from_sales interest free fees assets])
      expect(json_response[:totals][:assets][0][:currency]).to eq('BTC-USD')
    end

    it_behaves_like 'it returns a new jwt'
  end
end
