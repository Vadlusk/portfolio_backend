FactoryBot.define do
  factory :account do
    user
    name    { |n| "CoinbasePro#{n}" }
    balance { rand(-15000.00...1000000.00) }
    api_key { 'api_key' }
    secret  { 'secret' }
  end
end
