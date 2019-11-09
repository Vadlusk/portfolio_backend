class AuthenticationError < StandardError;
  class InvalidID < AuthenticationError
    def message
      'Client ID is invalid'
    end
  end

  class HeaderMissing < AuthenticationError
    def message
      'Authorization header is required'
    end
  end

  class MissingEmail < AuthenticationError
    def message
      'Email is required'
    end
  end

  class MissingPassword < AuthenticationError
    def message
      'Password is required'
    end
  end

  class InvalidPassword < AuthenticationError
    def message
      'Password is incorrect'
    end
  end

  class ResourceNotOwnedByRequester < AuthenticationError
    def message
      'Resource does not belong to current user'
    end
  end
end

class ApplicationController < ActionController::API
  include ErrorHandler
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_client_id
    result = authenticate_with_http_token do |token|
      ActiveSupport::SecurityUtils.secure_compare(token, ENV['client_id'])
    end

    raise AuthenticationError::HeaderMissing if result.nil?
    raise AuthenticationError::InvalidID unless result
  end

  def validate_presence_of_credentials
    raise AuthenticationError::MissingEmail if params[:email].nil?
    raise AuthenticationError::MissingPassword if params[:password].nil?
  end

  def authenticate_jwt
    jwt_user
  end

  def check_ownership
    raise AuthenticationError::ResourceNotOwnedByRequester unless User.find(params['id']) == jwt_user
  end

  def new_jwt
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
end
