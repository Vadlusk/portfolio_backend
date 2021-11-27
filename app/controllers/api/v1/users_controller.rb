# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_client_id, only: %i[authenticate create]
      before_action :authenticate_jwt, only: %i[destroy]

      def authenticate
        @user = User.find_by!(email: user_params[:email])

        @user.authenticate!(user_params[:password])

        render json: { token: new_jwt }, status: :ok

        # @user.update_history
      end

      def create
        @user = User.create!(user_params)

        render json: { token: new_jwt }, status: :created
      end

      def destroy
        jwt_user.destroy

        head :no_content
      end

      private

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
