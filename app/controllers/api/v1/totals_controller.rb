# frozen_string_literal: true

module Api
  module V1
    class TotalsController < ApplicationController
      before_action :authenticate_jwt

      def index
        render json: {
          totals: @jwt_user.totals,
          token: new_jwt
        }, status: :ok
      end
    end
  end
end
