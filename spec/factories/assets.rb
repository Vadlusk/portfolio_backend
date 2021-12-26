# frozen_string_literal: true

FactoryBot.define do
  factory :asset do
    account
    remote_id       { 'uuid' }
    current_balance { (0.00001..999999.0).to_s }
    currency        { 'BTC-USD' }
  end
end
