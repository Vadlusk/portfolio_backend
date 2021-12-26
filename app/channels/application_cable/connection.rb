# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      decoded_jwt = JsonWebToken.decode(token: request.params[:token])

      # self.current_user = User.find(decoded_jwt.first['user_id'])
    end
  end
end
