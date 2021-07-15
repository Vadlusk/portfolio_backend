class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.string :remote_id
      t.string :amount
      t.string :balance
      t.string :currency
      t.date :occurred_at
      t.column :transaction_type, :transaction_type, index: true
      t.jsonb :details

      t.references :account, foreign_key: true, index: true, on_delete: :cascade
    end

    add_index :transactions, :details, using: :gin
  end
end
