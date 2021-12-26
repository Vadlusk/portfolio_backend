# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    user

    sequence :name do |n|
      "name_#{n}"
    end
    
    factory :account_with_bitcoin do
      after(:create) do |account|
        create(:asset, account: account)
      end
    end
  end
end
