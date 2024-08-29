# frozen_string_literal: true

def next?
  File.basename(__FILE__) == "Gemfile.next"
end

source "https://rubygems.org"

ruby "3.2.2"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "avro_turf"

gem "aws-sdk-sqs"

# BGS
gem "bgs", git: "https://github.com/department-of-veterans-affairs/ruby-bgs.git",
           ref: "0ab9d0b8ded5cc8569368aa525bf7ef56b699c0e"

gem "benchmark"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "dotenv-rails"
gem "faraday-retry"
gem "hashie"

gem "httpclient"

gem "httpi"

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

gem "redis-namespace"

gem "request_store"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:windows, :jruby]

gem "immigrant"

gem "shoryuken"

gem "logstasher"

gem "jruby-openssl", platforms: :jruby

gem "redis-mutex"

gem "sentry-raven"

gem "statsd-instrument"

gem "strong_migrations"

gem "next_rails"

gem "opentelemetry-exporter-otlp", require: false
gem "opentelemetry-instrumentation-action_pack", require: false
gem "opentelemetry-instrumentation-active_job", require: false
gem "opentelemetry-instrumentation-active_model_serializers", require: false
gem "opentelemetry-instrumentation-active_record", require: false
gem "opentelemetry-instrumentation-active_support", require: false
gem "opentelemetry-instrumentation-aws_sdk", require: false
gem "opentelemetry-instrumentation-concurrent_ruby", require: false
gem "opentelemetry-instrumentation-excon", require: false
gem "opentelemetry-instrumentation-faraday", require: false
gem "opentelemetry-instrumentation-http_client", require: false
gem "opentelemetry-instrumentation-net_http", require: false
gem "opentelemetry-instrumentation-rack", require: false
gem "opentelemetry-instrumentation-rails", require: false
gem "opentelemetry-instrumentation-rake", require: false
gem "opentelemetry-instrumentation-rdkafka", require: false
gem "opentelemetry-sdk", require: false

gem "vcr"

group :development, :test do
  gem "brakeman"
  gem "bullet"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "byebug"
  gem "climate_control"
  gem "danger"
  gem "database_cleaner-active_record"
  gem "database_cleaner-redis"
  gem "debug", platforms: [:mri, :windows]
  gem "factory_bot_rails"
  gem "faker"
  gem "karafka-testing"
  gem "pry-byebug", "~> 3.10"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "simplecov"
  gem "simplecov-lcov"
  gem "sql_tracker"
  gem "timecop"
  gem "webmock"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "solargraph"
end
