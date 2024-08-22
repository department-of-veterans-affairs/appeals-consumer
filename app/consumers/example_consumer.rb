# frozen_string_literal: true

# Example consumer that prints messages payloads
class ExampleConsumer < ApplicationConsumer
  def consume
    message_arr = messages.map { |message| message.payload }
    Karafka.logger.info message_arr
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
