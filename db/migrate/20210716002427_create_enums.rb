# frozen_string_literal: true

class CreateEnums < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE TYPE entry_type_type AS ENUM ('buy', 'sell', 'interest', 'free', 'transfer');
    SQL
  end

  def down
    execute <<-SQL
      DROP TYPE entry_type_type;
    SQL
  end
end
