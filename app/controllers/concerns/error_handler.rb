# frozen_string_literal: true

UNAUTHORIZED_ERRORS = [AuthenticationError, JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError].freeze
UNPROCESSABLE_ENTITY_ERRORS = [ThirdPartyAuthenticationError, ActiveRecord::RecordInvalid].freeze

module ErrorHandler
  def self.included(klass)
    klass.class_eval do
      rescue_from ActiveRecord::RecordNotFound do |e|
        render_error(e, :not_found)
      end

      rescue_from(*UNAUTHORIZED_ERRORS) do |e|
        render_error(e, :unauthorized)
      end

      rescue_from(*UNPROCESSABLE_ENTITY_ERRORS) do |e|
        render_error(e, :unprocessable_entity)
      end
    end
  end

  private

  def render_error(e, status)
    render json: { error: e.message }, status: status
  end
end
