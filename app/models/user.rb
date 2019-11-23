class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_secure_password

  def authenticate!(password)
    raise AuthenticationError::InvalidPassword unless authenticate(password)
  end
end
