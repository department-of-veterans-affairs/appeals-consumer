require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  config.action_controller.perform_caching = false

  # set to true to create queues and override the sqs endpiont
  config.sqs_create_queues = true

  ENV['SHORYUKEN_SQS_ENDPOINT'] ||= 'http://localstack-consumer:4566'
  config.sqs_endpoint = ENV['SHORYUKEN_SQS_ENDPOINT']

  # since we mock aws using localstack, provide dummy creds to the aws gem
  ENV["AWS_ACCESS_KEY_ID"] ||= "dummykeyid"
  ENV["AWS_SECRET_ACCESS_KEY"] ||= "dummysecretkey"

  config.caseflow_url = ENV["CASEFLOW_URL"] ||= "http://host.docker.internal:3000"

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Needed to run rspec request tests
  config.hosts << "www.example.com"

  RequestStore.store[:current_user] = {
    css_id: ENV["CSS_ID"],
    station_id: ENV["STATION_ID"]
  }

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Max failed errors until event is switched to "failed"
  ENV["MAX_ERRORS_FOR_FAILURE"] ||= "4"

  config.api_key = "token"

  # Dynatrace variables
  ENV["STATSD_ENV"] = "development"

  # Local avro file for DecisionReviewCreated topic
  ENV["DECISION_REVIEW_CREATED_TOPIC"] ||= "BIA_SERVICES_BIE_CATALOG_LOCAL_DECISION_REVIEW_CREATED_V01"

  # Local avro file for DecisionReviewUpdated topic
  ENV["DECISION_REVIEW_UPDATED_TOPIC"] ||= "BIA_SERVICES_BIE_CATALOG_LOCAL_DECISION_REVIEW_UPDATED_V01"

  # Local avro file for DecisionReviewCompleted topic
  ENV["DECISION_REVIEW_COMPLETED_TOPIC"] ||= "BIA_SERVICES_BIE_CATALOG_LOCAL_DECISION_REVIEW_COMPLETED_V01"
end
