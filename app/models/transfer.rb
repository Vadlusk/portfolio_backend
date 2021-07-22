class Transfer < ApplicationRecord
  attribute :details, :integer, array: true, default: []
  attribute :account_name, :string

  validates_presence_of :remote_id, :remote_account_id, :currency

  enum withdraw_or_deposit: {
    withdraw: 'withdraw',
    deposit: 'deposit'
   }

  belongs_to :account
  has_many :transactions
end
