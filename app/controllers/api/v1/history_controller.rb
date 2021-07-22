class Api::V1::HistoryController < ApplicationController
  before_action :authenticate_jwt, only: %i[index]

  def index
    render json: { history: jwt_user.history, token: new_jwt }, status: :ok
  end
end
