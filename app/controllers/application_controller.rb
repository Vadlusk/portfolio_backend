class ApplicationError < StandardError; end

class ClientIDError < ApplicationError
  class InvalidID < ClientIDError; end
  class HeaderMissing < ClientIDError; end
end

class AuthenticationError < ApplicationError
  class MissingEmail < AuthenticationError; end
  class MissingPassword < AuthenticationError; end
  class InvalidPassword < AuthenticationError; end
  class ResourceNotOwnedByRequester < AuthenticationError; end
end

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ClientIDError::HeaderMissing, with: :render_auth_header_missing
  rescue_from ClientIDError::InvalidID, with: :render_invalid_client_id
  rescue_from AuthenticationError::MissingEmail, with: :render_missing_email
  rescue_from AuthenticationError::MissingPassword, with: :render_missing_password
  rescue_from AuthenticationError::InvalidPassword, with: :render_invalid_password
  rescue_from AuthenticationError::ResourceNotOwnedByRequester, with: :render_invalid_owner
  rescue_from JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError, with: :render_unauthorized

  def authenticate_client_id
    result = authenticate_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV['client_id'])
    end

    raise ClientIDError::HeaderMissing if result.nil?
    raise ClientIDError::InvalidID unless result
  end

  def validate_presence_of_credentials
    raise AuthenticationError::MissingEmail if params[:email].nil?
    raise AuthenticationError::MissingPassword if params[:password].nil?
  end

  def authenticate_jwt
    decoded_jwt
    jwt_user
  end

  def check_ownership
    raise AuthenticationError::ResourceNotOwnedByRequester unless User.find(params['id']) == jwt_user
  end

  def token
    JsonWebToken.encode(payload: { user_id: @user.id })
  end

  private

    def decoded_jwt
      JsonWebToken.decode(token: request_jwt)
    end

    def jwt_user
      @jwt_user ||= User.find(decoded_jwt.first['user_id'])
    end

    def request_jwt
      request.headers['Authorization']&.split('=')&.last
    end

    def render_error(message:, status:)
      render json: { error: message }, status: status
    end

    def render_unauthorized(e)
      render_error(message: e.message, status: :unauthorized)
    end

    def render_not_found(e)
      render_error(message: e.message, status: :not_found)
    end

    def render_unprocessable_entity(e)
      render_error(message: e.message, status: :unprocessable_entity)
    end

    def render_auth_header_missing
      render_error(message: 'Authorization header is required', status: :unauthorized)
    end

    def render_invalid_client_id
      render_error(message: 'Client ID is invalid', status: :unauthorized)
    end

    def render_invalid_owner
      render_error(message: 'Resource does not belong to current user', status: :unauthorized)
    end

    def render_invalid_password
      render_error(message: 'Password is incorrect', status: :unauthorized)
    end

    def render_missing_password
      render_error(message: 'Password is required', status: :unauthorized)
    end

    def render_missing_email
      render_error(message: 'Email is required', status: :unauthorized)
    end
end
