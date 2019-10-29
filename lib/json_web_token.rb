module JsonWebToken
  def self.encode(payload:, expiration: 3600)
    payload[:exp] = Time.now.to_i + expiration
    JWT.encode(payload, ENV['jwt_string'], ENV['jwt_encryption_algorithm'])
  end

  def self.decode(token:)
    JWT.decode(token, ENV['jwt_string'], true, algorithm: ENV['jwt_encryption_algorithm'])
  end
end
