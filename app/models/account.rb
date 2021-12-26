# frozen_string_literal: true

class Account < ApplicationRecord
  validates :api_key,  uniqueness: { scope: %i[user_id name],     conditions: -> { where.not(name: nil) } }
  validates :nickname, uniqueness: { scope: %i[user_id nickname], conditions: -> { where.not(nickname: nil) } }
  validates :nickname, uniqueness: { scope: %i[user_id],          conditions: -> { where(name: nil) } }

  belongs_to :user
  has_many :assets,       dependent: :destroy
  has_many :transactions, dependent: :destroy

  delegate :verify_credentials, to: :exchange_adapter
  delegate :fetch_history,      to: :exchange_adapter
  delegate :update_history,     to: :exchange_adapter

  private

  def exchange_adapter
    @exchange_adapter ||= Object.const_get("#{name}Adapter").new(self)
  end
end
