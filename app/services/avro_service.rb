# frozen_string_literal: true

# This class is used for encoding and decoding an event for/from an avro
class AvroService
  require "avro_turf/messaging"

  def initialize
    @avro = AvroTurf::Messaging.new(registry_url: ENV.fetch("SCHEMA_REGISTRY_URL"))
  end

  def encode(message, schema_name)
    MetricsService.record("Avro encode for #{message}",
                          service: :avro_service,
                          name: "AvroService.encode") do
      @avro.encode(
        message,
        subject: schema_name,
        version: ENV["SCHEMA_VERSION"],
        validate: true
      )
    end
  end

  def decode(message)
    MetricsService.record("Avro decode for #{message}",
                          service: :avro_service,
                          name: "AvroService.decode") do
      @avro.decode_message(message)
    end
  end
end
