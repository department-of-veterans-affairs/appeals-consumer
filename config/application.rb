require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppealsConsumer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # setup the deploy env environment variable
    ENV['DEPLOY_ENV'] ||= Rails.env

    config.eager_load_paths << Rails.root.join('lib')

    # set Shoryuken as the job queue adapter
    config.active_job.queue_adapter = :shoryuken

    # config for which SQS endpoint we should use. Override this for local testing
    config.sqs_create_queues = false
    config.sqs_endpoint = nil

    # sqs details
    config.active_job.queue_name_prefix = "appeals_consumer_" + ENV['DEPLOY_ENV']


    config.bgs_environment = ENV["BGS_ENVIRONMENT"] || "beplinktest"

    config.station_id = "317"
    config.css_id = "APPEALSCONSUMER1"
    config.redis_url = ENV["REDIS_URL_CACHE"]

    config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL_CACHE"], expires_in: 24.hours }

    # it's a safe assumption we're running on us-gov-west-1
    ENV["AWS_REGION"] ||= "us-gov-west-1"

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_key = ENV["CONSUMER_API_KEY"]
    config.api_only = true
  end
end
