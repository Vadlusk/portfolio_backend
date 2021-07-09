class Asset < ApplicationRecord
  validates :currency, presence: true
  validates :balance, presence: true
  validates :remote_id, presence: true

  belongs_to :account
end
