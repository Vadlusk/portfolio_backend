class ApplicationController < ActionController::API
  include ErrorHandler
  include Authentication

  def new_jwt
    JsonWebToken.encode(payload: { user_id: @user&.id || jwt_user&.id })
  end
end
