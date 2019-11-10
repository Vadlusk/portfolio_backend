module Authentication
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
