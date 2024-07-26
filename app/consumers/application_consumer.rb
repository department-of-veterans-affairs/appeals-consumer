# frozen_string_literal: true

# This class serves as the base consumer for all Karafka message consumption within the application.
# It abstracts common functionality needed across different consumers, such as event processing,
# logging, and error handling. This setup promotes reuse and consistency in handling incoming
# messages from Kafka topics.
class ApplicationConsumer < Karafka::BaseConsumer
  private

  # processes a given event, saving it to the database if it's new and logging the operation.
  def process_event(event, extra_details)
    # Determines if the event is new and not yet saved in the database.
    if event&.new_record?
      event.save

      yield event if block_given?
      log_consumption_job({
                            **extra_details,
                            event_id: event.id
                          })
    else
      log_repeat_consumption({
                               **extra_details,
                               event_id: event.id
                             })
    end
  end

  # Attempts to find or initialize a new event based on message metadata.
  # This method ensures that each event is uniquely identified by its partition and offset,
  # preventing duplicate processing of the same event.
  def handle_event_creation(message, event_type)
    event_type.find_or_initialize_by(
      partition: message.metadata.partition,
      offset: message.metadata.offset
    ) do |event|
      event.type = event_type.to_s
      event.message_payload = message.payload.message
    end
  end

  # Logs the start of an event consumption with extra details for diagnostic purposes.
  def log_consumption_start(extra_details)
    log_info("Starting consumption", extra_details)
  end

  # Logs the successful enqueueing of an event consumption into a processing job.
  def log_consumption_job(extra_details)
    log_info("Dropped Event into processing job", extra_details)
  end

  # Logs an attempt to process an event that already exists in the database, indicating no further action was taken.
  def log_repeat_consumption(extra_details)
    log_info("Event record already exists. Skipping enqueueing job", extra_details)
  end

  # Logs the start of an event consumption with extra details for diagnostic purposes.
  def log_consumption_end(extra_details)
    log_info("Completed consumption of message", extra_details)
  end

  # Provides logger information for Sentry in the event of consumer failure.
  def sentry_details(message, event_type)
    {
      type: event_type,
      partition: message.metadata.partition,
      offset: message.metadata.offset,
      message_payload: message.payload.message
    }
  end

  # Extra details to be included for logging purposes.
  # Pass optional consumer_specific_details as a hash to include more information if needed.
  def extra_details(message, event_type, consumer_specific_details: {})
    universal_details = {
      type: event_type,
      partition: message.metadata.partition,
      offset: message.metadata.offset
    }
    universal_details.merge(consumer_specific_details)
  end

  # Utility method for logging information with a consisten format, including the class name and optional details.
  def log_info(message, extra = {})
    full_message = "[#{self.class.name}] #{message}"
    full_message += " | #{extra.to_json}" unless extra.empty?
    Karafka.logger.info(full_message)
  end
end
