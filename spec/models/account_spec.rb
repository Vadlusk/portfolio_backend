# frozen_string_literal: true

require 'rails_helper'

describe Account do
  let(:name) { 'CoinbasePro' }
  let(:api_key) { 'api_key' }
  let(:secret) { 'secret' }
  let(:user_id) { create(:user)[:id] }

  subject!(:account) do
    Account.create(
      name: name,
      nickname: 'nickname',
      api_key: api_key,
      secret: secret,
      passphrase: 'passphrase',
      user_id: user_id
    )
  end

  describe 'validations' do
    it 'is valid with all attributes' do
      expect(account).to be_valid
    end

    it_behaves_like 'it is invalid without', %i[user_id]

    context 'with a name' do
      it 'has a unique nickname per name per user' do
        same_nickname = Account.create(
          nickname: 'nickname',
          name: name,
          user_id: user_id
        )
        different_nickname = Account.create(
          nickname: 'different_nickname',
          name: name,
          user_id: user_id
        )

        expect(same_nickname).to_not be_valid
        expect(different_nickname).to be_valid
      end

      it 'has a unique api_key per name per user' do
        same_api_key = Account.create(
          api_key: 'api_key',
          name: name,
          user_id: user_id
        )
        different_api_key = Account.create(
          api_key: 'different_api_key',
          name: name,
          user_id: user_id
        )

        expect(same_api_key).to_not be_valid
        expect(different_api_key).to be_valid
      end
    end

    context 'without a name' do
      it 'has a unique nickname per user' do
        Account.create(
          nickname: 'nickname',
          user_id: user_id
        )
        same_nickname = Account.create(
          nickname: 'nickname',
          user_id: user_id
        )
        different_nickname = Account.create(
          nickname: 'different_nickname',
          user_id: user_id
        )

        expect(same_nickname).to_not be_valid
        expect(different_nickname).to be_valid
      end
    end
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :assets }
    it { should have_many :transactions }
  end
end
