# frozen_string_literal: true

require 'rails_helper'

describe Order do
  subject!(:order) do
    Order.create!(
      remote_id: 'remote_id',
      account_id: create(:account, user_id: create(:user)[:id])[:id],
      market_or_limit: 'market_order',
      amount: '232.23323',
      currency: 'BTC-USD',
      price: '232.323',
      limit_price: '2313252.324',
      fees: '23.23323',
      side: 'buy',
      status: 'done',
      occurred_at: DateTime.new,
      requested_at: DateTime.new
    )
  end

  describe 'attributes' do
    it 'is valid with all attributes' do
      expect(order).to be_valid
    end

    it_behaves_like 'it is invalid without', %i[remote_id account_id currency market_or_limit side]
  end

  describe 'relationships' do
    it { should belong_to :account }
    it { should have_many :transactions }
  end
end
