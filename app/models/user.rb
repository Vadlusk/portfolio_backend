# frozen_string_literal: true

class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_secure_password

  has_many :accounts, dependent: :destroy

  def authenticate!(password)
    raise AuthenticationError::InvalidPassword unless authenticate(password)
  end

  def totals
    if accounts.count.zero?
      return {
        fiat_spent: nil,
        fiat_from_sales: nil,
        interest: nil,
        free: nil,
        fees: nil,
        assets: []
      }
    end

    current_totals = asset_totals && JSON.parse(asset_totals)
    asset_costs = average_asset_costs ? JSON.parse(average_asset_costs) : []

    all_assets = current_totals&.each do |asset|
      asset_cost = !asset_costs.empty? && asset_costs.select { |cost| cost['currency'] == asset['currency'] }[0]
      asset_cost ? asset.merge!(asset_cost) : nil
    end

    {
      fiat_spent: total('buy'),
      fiat_from_sales: total('sell'),
      interest: total('interest'),
      free: total('free'),
      fees: total_fees,
      assets: all_assets
    }
  end

  def update_history
    # if updated_at < 1.day.ago
    accounts.where('name IS NOT NULL').find_each(&:update_history)

    update_attribute(:updated_at, DateTime.now)
    # end
  end

  private

  def total(type)
    query = <<-SQL
      SELECT SUM(t.total_price)
      FROM users u
        JOIN accounts a ON u.id = a.user_id
        JOIN transactions t ON t.account_id = a.id
      WHERE user_id = #{id}
        AND t.entry_type = '#{type}'
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten[0]
  end

  def total_fees
    query = <<-SQL
      SELECT ROUND(SUM(t.fees), 2)
      FROM users u
        JOIN accounts a ON u.id = a.user_id
        JOIN transactions t ON t.account_id = a.id
      WHERE user_id = #{id}
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten[0]
  end

  def asset_totals
    query = <<-SQL
      WITH asset_totals AS (
        SELECT a.currency, SUM(a.current_balance) as total_balance
        FROM users u
          JOIN accounts ac ON u.id = ac.user_id
          JOIN assets a ON a.account_id = ac.id
        WHERE a.current_balance > 0
          AND user_id = #{id}
        GROUP BY currency
      )
      SELECT json_agg(at.*)
      FROM asset_totals at
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten[0]
  end

  def average_asset_costs
    query = <<-SQL
      WITH average_costs AS (
        SELECT
          a.currency,
          SUM(t.total_price) / SUM(t.amount) AS avg_cost
        FROM accounts ac
          JOIN assets a ON a.account_id = ac.id
          JOIN transactions t ON split_part(t.currency, '-', 1) = a.currency
        WHERE t.entry_type = 'buy'
          AND a.current_balance > 0
          AND user_id = #{id}
        GROUP BY a.currency
      )
      SELECT json_agg(ac.*)
      FROM average_costs ac
    SQL

    ActiveRecord::Base.connection.execute(query).values.flatten[0]
  end
end
