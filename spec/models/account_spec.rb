require 'rails_helper'

describe Account do
  let(:name) { 'CoinbasePro' }
  let(:api_key) { 'api_key' }
  let(:secret) { 'secret' }
  let(:category) { 'crypto_exchange' }
  let(:user_id) { create(:user)[:id] }

  subject!(:account) { Account.create!(
    name: name,
    api_key: api_key,
    secret: secret,
    passphrase: 'passphrase',
    category: category,
    user_id: user_id
  ) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(account).to be_valid
    end

    it_behaves_like 'it is invalid without', [:name, :api_key, :secret, :category, :user_id]

    it 'is invalid without a unique name for each user' do
      account_with_same_name_for_same_user = Account.create(
        name: name,
        api_key: api_key,
        secret: secret,
        category: category,
        user_id: user_id
      )
      account_with_same_name_for_different_user = Account.create(
        name: name,
        api_key: api_key,
        secret: secret,
        category: category,
        user_id: create(:user)[:id]
      )

      expect(account_with_same_name_for_same_user).to_not be_valid
      expect(account_with_same_name_for_different_user).to be_valid
    end
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :assets }
    it { should have_many :orders }
    it { should have_many :transfers }
    it { should have_many :transactions }
  end
end
