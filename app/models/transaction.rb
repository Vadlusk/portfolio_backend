class Transaction < ApplicationRecord
  attribute :account_name, :string

  validates_presence_of :remote_id, :entry_type, :currency

  enum entry_type: {
    transfer: 'transfer',
    match: 'match',
    fee: 'fee',
    rebate: 'rebate',
    conversion: 'conversion'
  }

  belongs_to :account
end
