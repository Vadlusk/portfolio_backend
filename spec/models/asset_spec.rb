require 'rails_helper'

describe Asset do
  subject!(:asset) { Asset.create!(
    remote_id: 'remote_id',
    account_id: create(:account, user_id: create(:user)[:id])[:id],
    current_balance: '39948.48',
    currency: 'BTC-USD'
  ) }

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(asset).to be_valid
    end

    it_behaves_like 'it is invalid without', [:remote_id, :account_id, :current_balance, :currency]
  end

  describe 'relationships' do
    it { should belong_to :account }
  end
end
