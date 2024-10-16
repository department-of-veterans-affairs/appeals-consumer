# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    karafka_config = { 'bootstrap.servers': "kafka:9092" }
    if ENV["RAILS_ENV"] == "production"
      karafka_config = {
        'bootstrap.servers': ENV["AWS_KAFKA_CLUSTER"],
        'security.protocol': "SASL_SSL",
        'sasl.username': ENV["KAFKA_USERNAME"],
        'sasl.password': ENV["KAFKA_PASSWORD"],
        'sasl.mechanisms': "PLAIN",
        'group.id': ENV["KAFKA_GROUP_ID"]
      }
    end
    config.kafka = karafka_config
    config.client_id = "Karafka-consumer"
    # Recreate consumers with each batch. This will allow Rails code reload to work in the
    # development mode. Otherwise Karafka process would not be aware of code changes
    config.consumer_persistence = !Rails.env.development?
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)
  # Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # This logger prints the producer development info using the Karafka logger.
  # It is similar to the consumer logger listener but producer oriented.
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(
      # Log producer operations using the Karafka logger
      Karafka.logger,
      # If you set this to true, logs will contain each message details
      # Please note, that this can be extensive
      log_messages: false
    )
  )

  routes.draw do
    consumer_group :decision_review_created_consumer_group do
      # Uncomment this if you use Karafka with ActiveJob
      # You need to define the topic per each queue name you use
      # active_job_topic :default
      topic ENV["DECISION_REVIEW_CREATED_TOPIC"] do
        # Uncomment this if you want Karafka to manage your topics configuration
        # Managing topics configuration via routing will allow you to ensure config consistency
        # across multiple environments
        #
        # config(partitions: 2, 'cleanup.policy': 'compact')
        consumer DecisionReviewCreatedConsumer
        deserializer AvroDeserializerService.new
      end
    end
    consumer_group :decision_review_updated_consumer_group do
      topic ENV["DECISION_REVIEW_UPDATED_TOPIC"] do
        consumer DecisionReviewUpdatedConsumer
        deserializer AvroDeserializerService.new
      end
    end
  end
end
