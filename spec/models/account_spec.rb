require 'rails_helper'

describe Account do
  let(:name) { 'CoinbasePro' }
  let(:api_key) { 'api_key' }
  let(:secret) { 'secret' }
  let(:user_id) { create(:user)[:id] }

  subject!(:account) { Account.create!(
    user_id: user_id,
    name: name,
    balance: 24332.32,
    api_key: api_key,
    secret: secret,
    passphrase: 'passphrase'
  ) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(account).to be_valid
    end

    it_behaves_like 'it is invalid without', [:name, :api_key, :secret]

    it 'is invalid without a unique name' do
      copy_cat = Account.create(name: name, api_key: api_key, secret: secret, user_id: user_id )

      expect(copy_cat).to_not be_valid
    end
  end

  describe 'relationships' do
    it { should belong_to :user }
  end
end
