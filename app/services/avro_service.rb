# frozen_string_literal: true

# This class is used for encoding and decoding an event for/from an avro
class AvroService
  require "avro_turf/messaging"

  def initialize
    @avro = AvroTurf::Messaging.new(registry_url: ENV.fetch("SCHEMA_REGISTRY_URL"))
  end

  def encode(message, schema_name)
    @avro.encode(
      message,
      subject: schema_name,
      version: 1,
      validate: true
    )
  end

  def decode(message)
    @avro.decode_message(message)
  end
end
