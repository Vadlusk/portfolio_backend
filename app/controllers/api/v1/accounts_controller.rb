# frozen_string_literal: true

INTERNAL_ATTRIBUTES = %i[api_key secret passphrase user_id updated_at created_at].freeze

module Api
  module V1
    class AccountsController < ApplicationController
      before_action :authenticate_jwt
      before_action :set_account, only: %i[update destroy]

      def create
        render json: {
          account: CreateAccount.new(params, jwt_user).run,
          token: new_jwt
        }.deep_transform_keys { |key| key.to_s.camelize(:lower) },
          status: :created,
          except: INTERNAL_ATTRIBUTES,
          include: %i[assets transactions]
      end

      def index
        render json: {
          accounts: Account.where(user_id: jwt_user.id),
          token: new_jwt
        }.deep_transform_keys { |key| key.to_s.camelize(:lower) },
          status: :ok,
          except: INTERNAL_ATTRIBUTES,
          include: %i[assets transactions]
      end

      def update
        byebug
        @account.update

        render json: { token: new_jwt }
      end

      def destroy
        @account.destroy

        render json: { token: new_jwt }
      end

      private

      def set_account
        @account ||= Account.find(params[:id])
      end

      def render_account(account, status)end
    end
  end
end
