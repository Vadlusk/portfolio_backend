class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    create_table :accounts do |t|
      t.string :name, null: false
      t.string :api_key, null: false
      t.string :secret, null: false
      t.string :passphrase
      t.column :category, :category_type, index: true, null: false

      t.timestamps
    end

    add_reference :accounts, :user, null: false, foreign_key: true, index: true, on_delete: :cascade

    create_table :assets do |t|
      t.string :remote_id, null: false
      t.string :current_balance, null: false
      t.string :currency, null: false
    end

    add_reference :assets, :account, null: false, foreign_key: true, index: true, on_delete: :cascade

    create_table :orders do |t|
      t.string :remote_id, null: false
      t.column :market_or_limit, :market_or_limit_type, index: true
      t.string :price
      t.string :executed_value
      t.string :amount
      t.string :currency, null: false
      t.column :side, :side_type, index: true, null: false
      t.string :total_fees
      t.column :status, :status_type, index: true

      t.datetime :occurred_at
      t.datetime :requested_at
      t.timestamps
    end

    add_reference :orders, :account, null: false, foreign_key: true, index: true, on_delete: :cascade

    create_table :transfers do |t|
      t.string :remote_id, null: false
      t.string :remote_account_id, null: false
      t.column :withdraw_or_deposit, :withdraw_or_deposit_type, index: true
      t.string :amount
      t.string :currency, null: false
      t.string :fees

      t.datetime :occurred_at
      t.timestamps
    end

    add_reference :transfers, :account, null: false, foreign_key: true, index: true, on_delete: :cascade

    create_table :transactions do |t|
      t.string :remote_id, null: false
      t.string :remote_order_id
      t.string :remote_transfer_id
      t.column :entry_type, :entry_type_type, index: true, null: false
      t.string :amount
      t.string :balance
      t.string :currency, null: false

      t.datetime :occurred_at
      t.timestamps
    end

    add_reference :transactions, :account, null: false, foreign_key: true, index: true, on_delete: :cascade
  end
end
