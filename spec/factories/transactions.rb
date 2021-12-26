# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    account

    sequence :remote_id do |n|
      "uuid_#{n}"
    end

    currency    { 'BTC' }
    entry_type  { %w[buy sell interest free transfer].sample }
    total_price { (0.00001..999999.0).to_s }
  end
end
