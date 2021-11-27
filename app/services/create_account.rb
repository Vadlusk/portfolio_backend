class CreateAccount
  def initialize(params, user)
    @params = params
    @user = user
  end

  def run
    account = @user.accounts.new(
      {
        name: @params[:name],
        nickname: @params[:nickname],
        api_key: @params[:api_key],
        secret: @params[:secret],
        passphrase: @params[:passphrase]
      }
    )

    if account.name && account.verify_credentials
      account.save!

      FetchHistoryJob.perform_later(account, @user)
    end

    if @params[:assets] # custom account
      @params.permit!

      account.save!

      @params[:assets].each do |asset|
        account.assets.create!(asset)
      end
    end

    account
  end
end
