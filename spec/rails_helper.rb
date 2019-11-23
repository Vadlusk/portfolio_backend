ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'spec_helper'
require 'simplecov'
require 'coveralls'

abort("The Rails environment is running in production mode!") if Rails.env.production?

SimpleCov.profiles.define 'no_jobs_channels_mailers' do
  load_profile 'rails'
  add_filter 'app/jobs'
  add_filter 'app/channels'
  add_filter 'app/mailers'
end

SimpleCov.start 'no_jobs_channels_mailers'
Coveralls.wear! 'rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
end
