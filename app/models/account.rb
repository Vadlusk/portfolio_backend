class Account < ApplicationRecord
  validates_presence_of :name, :balance

  belongs_to :user
end
