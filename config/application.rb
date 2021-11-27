# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module RailsJwtAuth
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app/**')
    config.eager_load_paths << Rails.root.join('lib')
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i[get post put delete options]
      end
    end

    config.active_record.schema_format = :sql
    config.api_only = true
  end
end
