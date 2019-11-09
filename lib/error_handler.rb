module ErrorHandler
  def self.included(klass)
    klass.class_eval do
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
      rescue_from AuthenticationError, with: :render_unauthorized
      rescue_from JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError, with: :render_unauthorized
    end
  end

  private

    def render_error(message, status)
      render json: { error: message }, status: status
    end

    def render_unauthorized(e)
      render_error(e.message, :unauthorized)
    end

    def render_not_found(e)
      render_error(e.message, :not_found)
    end

    def render_unprocessable_entity(e)
      render_error(e.message, :unprocessable_entity)
    end
end
