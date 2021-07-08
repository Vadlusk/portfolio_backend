FactoryBot.define do
  factory :account do
    user
    name    { %w[CoinbasePro Coinbase RobinHood].sample }
    balance { rand(-15000.00...1000000) }
  end
end
