# frozen_string_literal: true

class CreateTables < ActiveRecord::Migration[6.0]
  def change
    enable_extension('citext')

    create_table :users do |t|
      t.citext :email, null: false
      t.string :password_digest, null: false

      t.index :email, unique: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: true, on_delete: :cascade

      t.string :name
      t.string :nickname
      t.string :api_key
      t.string :secret
      t.string :passphrase

      t.index %i[user_id name nickname], unique: true

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end

    create_table :assets do |t|
      t.references :account, null: false, foreign_key: true, index: true, on_delete: :cascade

      t.string :remote_id
      t.string :currency, null: false
      t.decimal :current_balance, precision: 18, scale: 8, null: false

      t.index %i[account_id currency], unique: true
    end

    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true, index: true, on_delete: :cascade

      t.string :remote_id, null: false
      t.string :currency, null: false
      t.column :entry_type, :entry_type_type, index: true, null: false
      t.decimal :amount, precision: 18, scale: 8
      t.decimal :fees, precision: 18, scale: 8
      t.decimal :price_per_coin, precision: 18, scale: 8
      t.decimal :total_price, precision: 18, scale: 8
      t.string :details

      t.index %i[account_id remote_id], unique: true

      t.datetime :occurred_at
    end
  end
end
