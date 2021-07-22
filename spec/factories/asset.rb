FactoryBot.define do
  factory :asset do
    account
    remote_id       { 'uuid' }
    current_balance { '2352.235353' }
    currency        { 'BTC-USD' }
  end
end
