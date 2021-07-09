class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  has_secure_password

  has_many :accounts

  def authenticate!(password)
    raise AuthenticationError::InvalidPassword unless authenticate(password)
  end
end
