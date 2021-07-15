class CreateTransactionTypeEnum < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE transaction_type AS ENUM ('transfer', 'match', 'fee', 'rebate', 'conversion');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE transaction_type;
    SQL
  end
end
