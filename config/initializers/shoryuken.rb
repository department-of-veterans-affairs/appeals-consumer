# require "#{Rails.root}/app/jobs/middleware/job_monitoring_middleware"
# require "#{Rails.root}/app/jobs/middleware/job_request_store_middleware"
# require "#{Rails.root}/app/jobs/middleware/job_sentry_scope_middleware"

# set up default exponential backoff parameters
ActiveJob::QueueAdapters::ShoryukenAdapter::JobWrapper
  .shoryuken_options(retry_intervals: [15.seconds, 30.seconds, 1.minutes, 3.minutes, 5.minutes])
  if Rails.application.config.sqs_endpoint
    # override the sqs_endpoint
    Shoryuken.configure_client do |config|
      config.sqs_client = Aws::SQS::Client.new(
        region: ENV["AWS_REGION"],
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        endpoint:         URI(Rails.application.config.sqs_endpoint),
        verify_checksums: false
      )
    end

    Shoryuken.configure_server do |config|
      config.sqs_client = Aws::SQS::Client.new(
        region: ENV["AWS_REGION"],
        access_key_id: ENV["AWS_ACCESS_KEY_ID"],
        secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
        endpoint: URI(Rails.application.config.sqs_endpoint),
        verify_checksums: false
      )
    end
end

if Rails.application.config.sqs_create_queues
  # create the development queues
  Shoryuken::Client.sqs.create_queue({ queue_name: ActiveJob::Base.queue_name_prefix + '_high_priority' })
  Shoryuken::Client.sqs.create_queue({ queue_name: ActiveJob::Base.queue_name_prefix + '_low_priority' })
end

Shoryuken.configure_server do |config|
  # Configure loggers in Shoryuken.
  #
  # Note: `Rails.logger` and `ActiveRecord::Base.logger` are different in production. This only
  #   changes the formatter here to preserve the logging level of each logger.
  Rails.logger.formatter = Shoryuken.logger.formatter.dup.extend(ActiveSupport::TaggedLogging::Formatter)
  ActiveRecord::Base.logger.formatter = Shoryuken.logger.formatter.dup.extend(ActiveSupport::TaggedLogging::Formatter)

  # register all shoryuken middleware
  # config.server_middleware do |chain|
  #   chain.add JobMonitoringMiddleware
  #   chain.add JobRequestStoreMiddleware
  #   chain.add JobSentryScopeMiddleware
  # end
end
