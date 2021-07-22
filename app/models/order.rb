class Order < ApplicationRecord
  attribute :details, :integer, array: true, default: []
  attribute :account_name, :string

  validates_presence_of :remote_id, :currency, :market_or_limit, :side

  enum market_or_limit: {
    market_order: 'market_order',
    limit_order: 'limit_order'
  }

  enum status: {
    done: 'done',
    settled: 'settled',
    pending: 'pending',
    open: 'open',
    active: 'active'
  }

  belongs_to :account
  has_many :transactions, primary_key: :remote_id, foreign_key: :remote_order_id
end
