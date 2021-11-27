# frozen_string_literal: true

class Transaction < ApplicationRecord
  attribute :account_name, :string

  validates :remote_id, :entry_type, :currency, presence: true

  enum entry_type: {
    buy: 'buy',
    sell: 'sell',
    interest: 'interest',
    free: 'free',
    transfer: 'transfer'
  }

  belongs_to :account
end
