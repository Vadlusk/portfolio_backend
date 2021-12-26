# frozen_string_literal: true

require 'rails_helper'

describe 'DELETE /api/v1/accounts/:account_id' do
  include_context 'authenticated user'

  let(:account_id) { create(:account, user: user).id }
  let(:path)       { api_v1_account_path(account_id) }

  include_examples 'a JWT protected endpoint', :delete

  context 'with valid credentials' do
    before do
      expect { Account.find(account_id) }.to_not raise_error

      delete path, headers: headers
    end

    it 'deletes the account' do
      expect { Account.find(account_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'responds with a 204' do
      expect(response.status).to eq(204)
    end
  end
end
