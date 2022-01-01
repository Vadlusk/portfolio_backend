# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.9'

gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap'
gem 'faraday'
gem 'ffi', '~> 1.15.3'
gem 'figaro'
gem 'jwt'
gem 'listen'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '>= 4.3.9'
gem 'rack-cors'
gem 'rails', '~> 6.1.4'
gem 'redis', '~> 4.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rubocop', '~> 0.77.0'
end

group :test do
  gem 'coveralls_reborn', '~> 0.18.0', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'simplecov',      require: false
  gem 'simplecov-lcov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
