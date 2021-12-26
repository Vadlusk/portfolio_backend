# frozen_string_literal: true

require 'rails_helper'

describe Asset do
  let(:current_balance) { 39_948.48 }
  let(:account_id)      { create(:account, user_id: create(:user)[:id])[:id] }

  subject!(:asset) do
    Asset.create(
      remote_id: 'remote_id',
      currency: 'BTC-USD',
      current_balance: current_balance,
      account_id: account_id
    )
  end

  describe 'field validations' do
    it 'is valid with all attributes' do
      expect(asset).to be_valid
    end

    it_behaves_like 'it is invalid without', %i[account_id current_balance currency]

    it 'has a unique currency per account' do
      Asset.create(
        currency: 'currency',
        current_balance: current_balance,
        account_id: account_id
      )
      same_currency = Asset.create(
        currency: 'currency',
        current_balance: current_balance,
        account_id: account_id
      )
      different_currency = Asset.create(
        currency: 'different_currency',
        current_balance: current_balance,
        account_id: account_id
      )

      expect(same_currency).to_not be_valid
      expect(different_currency).to be_valid
    end
  end

  describe 'relationships' do
    it { should belong_to :account }
  end
end
