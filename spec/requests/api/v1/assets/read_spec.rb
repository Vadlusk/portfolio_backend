# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/assets/:asset_id' do
  include_context 'authenticated user'

  let(:asset_id) { create(:asset, account: create(:account, user: user)).id }
  let(:path)     { api_v1_asset_path(asset_id) }

  include_examples 'a JWT protected endpoint', :get

  context 'with valid credentials' do
    before(:each) do
      get path, headers: headers
    end

    it 'responds with a 200' do
      expect(response.status).to eq(200)
    end

    skip 'returns the asset' do
      # WIP
    end

    it_behaves_like 'it returns a new jwt'
  end
end
