# frozen_string_literal: true

class AuthenticationError < StandardError
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
end
