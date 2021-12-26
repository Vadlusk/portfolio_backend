# frozen_string_literal: true

require 'rails_helper'

describe 'DELETE /api/v1/users/:id' do
  include_context 'authenticated user'

  let(:path) { api_v1_users_path(user) }

  it_behaves_like 'a JWT protected endpoint', :delete

  context 'with valid credentials' do
    before do
      expect { User.find(user.id) }.to_not raise_error

      delete path, headers: headers
    end

    it 'deletes the JWT\'s user' do
      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'responds with a 204' do
      expect(response.status).to eq(204)
    end
  end
end
