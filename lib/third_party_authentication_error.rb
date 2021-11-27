# frozen_string_literal: true

class ThirdPartyAuthenticationError < StandardError
  class InvalidApiKey < ThirdPartyAuthenticationError
    def message
      'API key is invalid'
    end
  end

  class InvalidSecret < ThirdPartyAuthenticationError
    def message
      'secret is invalid'
    end
  end

  class InvalidPassphrase < ThirdPartyAuthenticationError
    def message
      'passphrase is invalid'
    end
  end
end
