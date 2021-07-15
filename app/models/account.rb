class Account < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :user_id
  validates :api_key, presence: true
  validates :secret, presence: true
  enum category: {
    crypto_exchange: 'crypto_exchange',
    wallet: 'wallet',
    brokerage: 'brokerage'
   }

  belongs_to :user
  has_many :assets
  has_many :transactions
end
