class Api::V1::AccountsController < ApplicationController
  before_action :authenticate_jwt, only: %i[index]

  def index
    accounts = Account.where(user_id: jwt_user.id)

    render json: { accounts: accounts, token: new_jwt }, status: :ok
  end
end
