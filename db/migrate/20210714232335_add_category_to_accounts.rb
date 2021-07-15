class AddCategoryToAccounts < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE category_type AS ENUM ('crypto_exchange', 'wallet', 'brokerage');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE category_type;
    SQL
  end
end
