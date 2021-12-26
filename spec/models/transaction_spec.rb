# frozen_string_literal: true

require 'rails_helper'

describe Transaction do
  let(:account_id) { create(:account, user_id: create(:user)[:id])[:id] }

  subject!(:transaction) do
    Transaction.create(
      remote_id: 'remote_id',
      currency: 'BTC-USD',
      entry_type: 'buy',
      amount: 232.23323,
      fees: 23.23323,
      price_per_coin: 1.323,
      total_price: 232.323,
      details: 'details',
      account_name: 'account_name',
      account_id: account_id,
      occurred_at: DateTime.new
    )
  end

  describe 'validations' do
    it 'is valid with all attributes' do
      expect(transaction).to be_valid
    end

    it_behaves_like 'it is invalid without', %i[account_id remote_id currency entry_type]
  end

  describe 'relationships' do
    it { should belong_to :account }
  end
end
