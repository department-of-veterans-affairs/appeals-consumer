def next?
  File.basename(__FILE__) == "Gemfile.next"
end
# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.2"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "aws-sdk-sqs"

gem "bgs", git: "https://github.com/department-of-veterans-affairs/ruby-bgs.git", ref: "7d7c67f7bad5e5aa03e257f0d8e57a4aa1a6cbbf"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "dotenv-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

gem "karafka", "~> 2.2"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.2"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

gem 'redis-namespace'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

gem 'immigrant'

gem 'shoryuken'

gem 'logstasher'

gem 'redis-mutex'

gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"
gem "sentry-delayed_job"
gem "sentry-resque"

gem "strong_migrations"

gem 'next_rails'

gem 'vcr'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "byebug"
  gem "debug", platforms: [:mri, :windows]
  gem "factory_bot_rails"
  gem "karafka-testing"
  gem "pry-byebug", "~> 3.10"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem 'database_cleaner-active_record'
  gem 'database_cleaner-redis'
  gem 'faker'
  gem 'danger'
  gem 'bullet'
  gem 'brakeman'
  gem 'simplecov', require: false
  gem 'sql_tracker'
  gem "webmock"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "solargraph"
end
