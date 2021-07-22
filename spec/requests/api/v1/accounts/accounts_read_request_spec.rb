require 'rails_helper'

describe 'GET /api/v1/accounts' do
  let(:user)    { create(:user) }
  let(:jwt)     { JsonWebToken.encode(payload: { user_id: user.id }) }
  let(:headers) { { 'Authorization': "Basic token=#{jwt}" } }
  let(:path)    { api_v1_accounts_path }

  it_behaves_like 'a JWT protected endpoint', :get

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
      expect(json_response[:accounts].length).to eq(1)
      expect(json_response[:accounts][0].keys).to contain_exactly(*ACCOUNT_ATTRS)
    end

    it 'returns a new jwt' do
      expect { JsonWebToken.decode(token: json_response[:token]) } .to_not raise_error
    end
  end
end
