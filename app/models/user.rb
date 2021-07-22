class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_secure_password

  has_many :accounts

  def authenticate!(password)
    raise AuthenticationError::InvalidPassword unless authenticate(password)
  end

  def history
    query = <<-SQL
      WITH orders_and_transfers_agg AS (
        SELECT
          t.id,
          CAST(t.withdraw_or_deposit AS VARCHAR) as record_type,
          a.name AS account_name,
          t.account_id,
          t.amount,
          t.occurred_at,
          t.fees AS total_fees,
          t.currency,

          NULL AS price,
          NULL AS executed_value,
          NULL AS side,
          NULL AS requested_at
        FROM transfers t
          LEFT JOIN accounts a ON a.id = t.account_id
        GROUP BY 1, a.name

        UNION

        SELECT
          o.id,
          CAST(o.market_or_limit AS VARCHAR),
          a.name AS account_name,
          o.account_id,
          o.amount,
          o.occurred_at,
          o.total_fees,
          o.currency,

          o.price,
          o.executed_value,
          o.side,
          o.requested_at
        FROM orders o
          LEFT JOIN accounts a ON a.id = o.account_id
        WHERE o.status = 'done'
        GROUP BY 1, a.name
      ), accounts_agg AS (
        SELECT
          date_trunc('day', ota.occurred_at) AS title,
          json_agg(ota.*) AS data
        FROM accounts a
          LEFT JOIN orders_and_transfers_agg ota ON ota.account_id = a.id
        WHERE a.user_id = 1
        GROUP BY date_trunc('day', ota.occurred_at)
        ORDER BY date_trunc('day', ota.occurred_at) DESC
      )
      SELECT json_agg(aa.*) AS history
      FROM accounts_agg aa;
    SQL

    ActiveRecord::Base.connection.execute(query).values
  end
end
