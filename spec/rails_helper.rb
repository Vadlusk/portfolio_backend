# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'spec_helper'
require 'simplecov'
require 'coveralls'

abort('The Rails environment is running in production mode!') if Rails.env.production?

SimpleCov.start 'rails' do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter %w[version.rb initializer.rb]
  add_filter 'app/jobs'
  add_filter 'app/channels'
  add_filter 'app/mailers'
end
Coveralls.wear! 'rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_str.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include Rails.application.routes.url_helpers # allows path helper methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
