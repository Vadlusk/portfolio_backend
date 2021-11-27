# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    password         { SecureRandom.hex(10) }
    sequence(:email) { Faker::Internet.unique.email }
  end
end
