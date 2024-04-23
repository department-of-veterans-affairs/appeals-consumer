# frozen_string_literal: true

class AvroDeserializerService
  require "avro_turf/messaging"

  def initialize
    @avro = AvroTurf::Messaging.new(
      registry_url: ENV.fetch("SCHEMA_REGISTRY_URL"),
      logger: AvroLoggerService.new($stdout),
      user: ENV["KAFKA_USERNAME"],
      password: ENV["KAFKA_PASSWORD"]
    )
  end

  def call(message)
    MetricsService.record("Avro deserializing for #{message}",
                          service: :avro_deserializer,
                          name: "AvroDeserializerService.call") do
      decoded_message = decode_avro_message(message)
      transformed_message_payload = transform_payload_to_snakecase(decoded_message)

      AvroTurf::Messaging::DecodedMessage.new(decoded_message.schema_id,
                                              decoded_message.writer_schema,
                                              decoded_message.reader_schema,
                                              transformed_message_payload)
    end
  end

  private

  def decode_avro_message(message)
    @avro.decode_message(message.raw_payload)
  end

  def transform_payload_to_snakecase(payload)
    payload.message.deep_transform_keys { |key| key.to_s.underscore }
  end
end
