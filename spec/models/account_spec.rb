require 'rails_helper'

describe Account do
  let(:name)    { 'CoinbasePro' }
  let(:balance) { 24332.32 }

  subject!(:account) { Account.create(name: name, balance: balance, user_id: create(:user)[:id]) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(account).to be_valid
    end

    it_behaves_like 'it is invalid without', [:name, :balance]
  end

  describe 'relationships' do
    it { should belong_to :user }
  end
end
