# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :remote_id, :entry_type, :currency, presence: true

  attribute :account_name, :string

  enum entry_type: {
    buy: 'buy',
    sell: 'sell',
    interest: 'interest',
    free: 'free',
    transfer: 'transfer'
  }

  belongs_to :account
end
