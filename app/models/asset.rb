# frozen_string_literal: true

class Asset < ApplicationRecord
  validates :current_balance, :currency, presence: true
  validates :currency, uniqueness: { scope: %i[account_id] }

  belongs_to :account

  def history
    query = <<-SQL
      WITH history_agg AS (
        SELECT
          ac.id AS account_id,
          date_trunc('day', t.occurred_at) AS title,
          json_agg((
            SELECT x FROM (SELECT ac.name, t.*) AS x
            WHERE t.account_id IS NOT NULL
          )) AS data
        FROM transactions t
          LEFT JOIN accounts ac ON t.account_id = ac.id
        WHERE ac.user_id = #{account.user_id}
          AND t.currency LIKE '#{currency}%'
        GROUP BY ac.id, date_trunc('day', t.occurred_at)
      )
      SELECT
        json_agg((
          SELECT x FROM (
            SELECT ha.title, ha.data
            ORDER BY ha.title DESC
          ) AS x
        )) AS transaction_history
      FROM assets a
        JOIN accounts ac ON a.account_id = ac.id
        JOIN history_agg ha ON ha.account_id = ac.id
      WHERE a.current_balance != 0
        AND a.currency = '#{currency}'
        AND ac.user_id = #{account.user_id}
      GROUP BY a.currency
    SQL

    parse_query_results(query)
  end
end
