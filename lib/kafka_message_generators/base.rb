# frozen_string_literal: true

module KafkaMessageGenerators::Base
  class << self
    def camelize_keys(message)
      hash = convert_message_to_hash(message)
      hash.deep_transform_keys! { |key| key.camelize(:lower) }
    end

    def convert_message_to_hash(message)
      json = message.to_json
      hash = JSON.parse(json)
      hash.delete("event_id")
      hash
    end

    # encode message before publishing
    def encode_message(message, topic)
      AvroService.new.encode(message, topic)
    end

    # publish message to the DecisionReviewCreated topic
    def publish_message(encoded_message, topic)
      @published_messages_count ||= 0
      Karafka.producer.produce_sync(
        topic: topic,
        payload: encoded_message
      )
      @published_messages_count += 1
    end
  end
end