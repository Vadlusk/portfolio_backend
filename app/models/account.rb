# frozen_string_literal: true

class Account < ApplicationRecord
  validates :nickname, uniqueness: { scope: %i[user_id name] }
  validates :api_key, uniqueness: { scope: %i[user_id name] }

  belongs_to :user

  has_many :assets, dependent: :delete_all
  has_many :transactions, dependent: :delete_all

  def verify_credentials
    exchange_adapter.verify_credentials
  end

  def fetch_history
    exchange_adapter.fetch_history
  end

  def update_history
    exchange_adapter.update_history
  end

  private

  def exchange_adapter
    @exchange_adapter ||= Object.const_get("#{name}Adapter").new(self)
  end
end
