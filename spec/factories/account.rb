FactoryBot.define do
  factory :account do
    user
    name     { 'CoinbasePro' }
    api_key  { 'api_key' }
    secret   { 'secret' }
    category { 'crypto_exchange' }
  end
end
