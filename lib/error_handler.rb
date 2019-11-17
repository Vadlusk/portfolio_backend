module ErrorHandler
  def self.included(klass)
    klass.class_eval do
      rescue_from ActiveRecord::RecordNotFound do |e|
        render_error(e, :not_found)
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render_error(e, :unprocessable_entity)
      end

      rescue_from AuthenticationError, JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError do |e|
        render_error(e, :unauthorized)
      end
    end
  end

  private

    def render_error(e, status)
      render json: { error: e.message }, status: status
    end
end
