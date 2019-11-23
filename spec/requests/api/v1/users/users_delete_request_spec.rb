require 'rails_helper'

describe 'DELETE /api/v1/users/:id' do
  let(:path)    { api_v1_user_path(user) }
  let(:user)    { create(:user) }
  let(:jwt)     { JsonWebToken.encode(payload: { user_id: user.id }) }
  let(:headers) { { 'Authorization': "Basic token=#{jwt}" } }

  it_behaves_like 'a JWT protected endpoint', :delete

  context 'with valid credentials' do
    before do
      expect { User.find(user.id) } .to_not raise_error

      delete path, headers: headers
    end

    it 'responds with a 204' do
      expect(response.status).to eq(204)
    end

    it 'deletes a user' do
      expect { User.find(user.id) } .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when URI\'s user ID is invalid' do
    it 'responds with a 404' do
      delete api_v1_user_path('not_a_user'), headers: headers

      expected_error(status: 404, message: "Couldn't find User with 'id'=not_a_user")
    end
  end

  context 'when JWT\'s user ID is valid and does not match user ID in URI' do
    let(:wrong_user) { create(:user, email: 'wrong@email.com') }

    it 'responds with a 401' do
      delete api_v1_user_path(wrong_user), headers: headers

      expected_error(status: 401, message: 'Resource does not belong to current user')
    end
  end
end
