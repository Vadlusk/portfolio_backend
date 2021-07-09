class CreateTables < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest

      t.timestamps
    end

    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: true, on_delete: :cascade

      t.string :name, null: false
      t.integer :balance
      t.string :api_key, null: false
      t.string :secret, null: false
      t.string :passphrase

      t.timestamps
    end

    create_table :assets do |t|
      t.string :remote_id
      t.string :balance
      t.string :currency

      t.references :account, foreign_key: true, index: true, on_delete: :cascade

      t.timestamps
    end
  end
end
