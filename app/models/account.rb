class Account < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :api_key, presence: true
  validates :secret, presence: true

  belongs_to :user
  has_many :assets
end
