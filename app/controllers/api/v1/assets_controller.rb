# frozen_string_literal: true

module Api
  module V1
    class AssetsController < ApplicationController
      before_action :authenticate_jwt
      before_action :set_asset

      def show
        render json: {
          history: @asset.history,
          token: new_jwt
        }, status: :ok
      end

      private

      def set_asset
        @asset ||= Asset.find(params[:id])
      end
    end
  end
end
