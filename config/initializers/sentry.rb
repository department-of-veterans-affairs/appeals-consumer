Raven.configure do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.processors -= [Raven::Processor::PostData] # include POST data (excluded by default)
end
