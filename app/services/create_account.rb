class CreateAccount
  def initialize(params, user_id)
    @params = params
    @user_id = user_id
  end

  def create!
    connection = CallExchange.new(@params)

    account = Account.create!(@params.merge(user_id: @user_id))

    raw_assets = connection.assets

    raw_assets.each do |asset|
      account.assets.create!(
        currency: asset[:currency],
        balance: asset[:balance],
        remote_id: asset[:id]
      ).as_json.symbolize_keys!
    end

    raw_history = connection.history(raw_assets.map { |asset| asset[:id] })

    raw_history.flatten.each do |transaction|
      account.transactions.create!(
        remote_id: transaction[:id],
        amount: transaction[:amount],
        balance: transaction[:balance],
        currency: transaction[:details][:product_id],
        occurred_at: transaction[:created_at],
        transaction_type: transaction[:transaction_type],
        details: transaction[:details]
      ).as_json.symbolize_keys!
    end

    account
  end
end
