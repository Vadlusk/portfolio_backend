INTERNAL_ATTRIBUTES = %i[api_key secret passphrase]

class Api::V1::AccountsController < ApplicationController
  before_action :authenticate_jwt, only: %i[create index]

  def create
    account = Account.create!(coin_params.merge(user_id: jwt_user.id))

    render json: { account: account, token: new_jwt }, status: :created, except: INTERNAL_ATTRIBUTES
  end

  def index
    accounts = Account.where(user_id: jwt_user.id)

    render json: { accounts: accounts, token: new_jwt }, status: :ok, except: INTERNAL_ATTRIBUTES
  end

  private

    def coin_params
      params.permit(:name, :api_key, :secret, :passphrase)
    end
end
