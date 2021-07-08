class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true, index: true, on_delete: :cascade

      t.string :name
      t.integer :balance

      t.timestamps
    end
  end
end
