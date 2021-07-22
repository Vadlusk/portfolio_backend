class Account < ApplicationRecord
  validates_presence_of :name, :api_key, :secret, :category
  validates_uniqueness_of :name, scope: :user_id

  enum category: {
    crypto_exchange: 'crypto_exchange',
    wallet: 'wallet',
    brokerage: 'brokerage'
  }

  belongs_to :user

  has_many :assets
  has_many :orders
  has_many :transfers
  has_many :transactions

  def fetch_history
    fetch_assets
    fetch_orders
    fetch_transfers
    fetch_transactions
  end

  private

    def connection
      @connection ||= CallExchange.new({ api_key: api_key, secret: secret, passphrase: passphrase })
    end

    def fetch_assets
      connection.assets.each do |asset|
        assets.create!(
          remote_id: asset[:id],
          current_balance: asset[:balance],
          currency: asset[:currency]
        ).as_json.symbolize_keys!
      end
    end

    def fetch_orders
      connection.orders.each do |order|
        orders.create!(
          remote_id: order[:id],
          market_or_limit: order[:type] + '_order',
          price: order[:price],
          total_fees: order[:fill_fees],
          executed_value: order[:executed_value],
          amount: order[:size],
          currency: order[:product_id],
          side: order[:side],
          status: order[:status],
          occurred_at: order[:done_at],
          requested_at: order[:created_at]
        ).as_json.symbolize_keys!
      end
    end

    def fetch_transfers
      connection.transfers.each do |transfer|
        transfers.create!(
          remote_id: transfer[:id],
          remote_account_id: transfer[:account_id],
          withdraw_or_deposit: transfer[:type],
          amount: transfer[:amount],
          currency: transfer[:currency] || Asset.where(remote_id: transfer[:account_id]).first.currency,
          fees: transfer[:details] ? transfer[:details][:fee] : nil,
          occurred_at: transfer[:completed_at] || transfer[:created_at]
        )
      end
    end

    def fetch_transactions
      connection.transactions(assets.map { |asset| asset[:remote_id] }).flatten.each do |transaction|
        byebug if transaction[:type] == 'rebate' || transaction[:type] == 'conversion'
        transactions.create!(
          remote_id: transaction[:id],
          remote_order_id: transaction[:details][:order_id],
          remote_transfer_id: transaction[:details][:transfer_id],
          entry_type: transaction[:type],
          amount: transaction[:amount],
          balance: transaction[:balance],
          currency: transaction[:details][:product_id] || Transfer.where(remote_id: transaction[:details][:transfer_id]).first.currency,
          occurred_at: transaction[:created_at]
        ).as_json.symbolize_keys!
      end
    end
end
