# # spec/kafka_consumer_spec.rb
require 'rails_helper'

describe ExampleConsumer do
#    This will create a consumer instance with all the settings defined for the given topic
  subject(:consumer) { karafka.consumer_for('example') }

  test_message = { 'number' => 'string' }

  before do
    # Sends first message to Karafka consumer
    karafka.produce(test_message.to_json)

    allow(Karafka.logger).to receive(:info)
  end

  it 'expects to log a proper message' do
    expect(Karafka.logger).to receive(:info).with([test_message])
    consumer.consume
  end
end