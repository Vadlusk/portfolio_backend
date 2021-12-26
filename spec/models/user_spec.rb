# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:email)    { 'email@email.com' }
  let(:password) { 'password' }

  subject!(:user) { User.create(email: email, password: password) }

  describe 'validations' do
    it 'is valid with all attributes' do
      expect(user).to be_valid
    end

    it_behaves_like 'it is invalid without', %i[email password]

    it 'is invalid without a unique email' do
      copy_cat = User.new(email: email, password: password)

      expect(copy_cat).to_not be_valid
    end
  end

  describe 'relationships' do
    it { should have_many :accounts }
  end

  describe '#authenticate!' do
    context 'with a correct password' do
      it 'does not raise an error' do
        expect { user.authenticate!(password) }.to_not raise_error
      end
    end

    context 'with an incorrect password' do
      it 'raises an error' do
        expect { user.authenticate!('incorrect_password') }.to \
          raise_error AuthenticationError::InvalidPassword
      end
    end
  end

  describe '#totals' do
    context 'with accounts and transactions' do
      it 'returns the total of all buy transactions\' total prices' do
        create_list(:transaction, 4, entry_type: 'buy', total_price: 25.25, account: create(:account, user: user))

        expect(user.totals[:fiat_spent]).to eq(101)
      end

      it 'returns the total of all sell transactions\' total prices' do
        create_list(:transaction, 4, entry_type: 'sell', total_price: 25.25, account: create(:account, user: user))

        expect(user.totals[:fiat_from_sales]).to eq(101)
      end

      it 'returns the total of all interest earned' do
        create_list(:transaction, 4, entry_type: 'interest', total_price: 25.25, account: create(:account, user: user))

        expect(user.totals[:interest]).to eq(101)
      end

      it 'returns the total of all free coins\' value in USD' do
        create_list(:transaction, 4, entry_type: 'free', total_price: 25.25, account: create(:account, user: user))

        expect(user.totals[:free]).to eq(101)
      end

      it 'returns the total of all fees' do
        account = create(:account, user: user)
        create(:transaction, entry_type: 'buy', fees: 25.25, account: account)
        create(:transaction, entry_type: 'sell', fees: 25.25, account: account)
        create(:transaction, entry_type: 'transfer', fees: 25.25, account: account)

        expect(user.totals[:fees]).to eq(75.75)
      end

      it 'returns each assets\' total balance' do
        accounts = create_list(:account, 4, user: user)

        accounts.each do |account|
          create(:asset, currency: 'BTC', current_balance: 25, account: account)
          create(:asset, currency: 'ETH', current_balance: 25, account: account)
          create(:asset, currency: 'ADA', current_balance: 25, account: account)
        end

        expect(user.totals[:assets][0]).to eq({ "currency" => 'ADA', "total_balance" => 100.0 })
        expect(user.totals[:assets][1]).to eq({ "currency" => 'BTC', "total_balance" => 100.0 })
        expect(user.totals[:assets][2]).to eq({ "currency" => 'ETH', "total_balance" => 100.0 })
      end
    end

    context 'without any accounts associated to the user' do
      it 'returns nil values for all metrics' do
        expect(user.totals).to eq(
          fiat_spent: nil,
          fiat_from_sales: nil,
          interest: nil,
          free: nil,
          fees: nil,
          assets: []
        )
      end
    end
  end
end
