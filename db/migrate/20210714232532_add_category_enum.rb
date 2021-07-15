class AddCategoryEnum < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :category, :category_type, index: true
  end
end
