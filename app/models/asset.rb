class Asset < ApplicationRecord
  validates_presence_of :remote_id, :current_balance, :currency 

  belongs_to :account
end
