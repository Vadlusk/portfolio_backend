class CreateEnums < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE category_type AS ENUM ('crypto_exchange', 'wallet', 'brokerage');
      CREATE TYPE withdraw_or_deposit_type AS ENUM ('withdraw', 'deposit');
      CREATE TYPE side_type AS ENUM ('buy', 'sell');
      CREATE TYPE market_or_limit_type AS ENUM ('market_order', 'limit_order');
      CREATE TYPE status_type AS ENUM ('done', 'settled', 'pending', 'open', 'active');
      CREATE TYPE entry_type_type AS ENUM ('transfer', 'match', 'fee', 'rebate', 'conversion');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE category_type;
      DROP TYPE withdraw_or_deposit_type;
      DROP TYPE side_type;
      DROP TYPE market_or_limit_type;
      DROP TYPE status_type;
      DROP TYPE entry_type_type;
    SQL
  end
end
