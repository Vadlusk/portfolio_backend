class Api::V1::UsersController < ApplicationController
  before_action :authenticate_client_id, only: %i[authenticate create]
  before_action :authenticate_jwt, only: %i[destroy]
  before_action :check_ownership, only: %i[destroy]

  def authenticate
    @user = User.find_by_email!(user_params[:email])

    @user.authenticate_with_error(user_params[:password])

    render json: { user_id: @user.id, token: new_jwt }, status: :ok
  end

  def create
    @user = User.create!(user_params)

    render json: { user_id: @user.id, token: new_jwt }, status: :created
  end

  def destroy
    User.find(params[:id]).destroy!
  end

  private

    def user_params
      params.permit(:email, :password)
    end
end
