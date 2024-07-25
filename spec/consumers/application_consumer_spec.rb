# frozen_string_literal: true

describe ApplicationConsumer do
  subject { ApplicationConsumer.new }
  let(:consumer) { described_class.new }
  let(:event_type) { Events::DecisionReviewUpdatedEvent }
  let(:message) { instance_double("Message", payload: payload, metadata: metadata) }
  let(:payload) { double("Payload", message: { "claim_id" => 345 }) }
  let(:metadata) { double("Metadata", offset: 10, partition: 1) }

  describe "log_info" do
    let(:message) { "Test message" }
    let(:extra_details) { { key: "value" } }

    before do
      allow(Karafka.logger).to receive(:info)
    end

    context "when extra details are provided" do
      it "logs the message with class name and extra details as JSON" do
        consumer.send(:log_info, message, extra_details)

        expected_message = "[#{described_class.name}] #{message} | #{extra_details.to_json}"
        expect(Karafka.logger).to have_received(:info).with(expected_message)
      end
    end

    context "when no extra details are provided" do
      it "logs the message with only the class name" do
        consumer.send(:log_info, message)

        expected_message = "[#{described_class.name}] #{message}"
        expect(Karafka.logger).to have_received(:info).with(expected_message)
      end
    end
  end

  describe "#sentry_details" do
    it "appropriately collects and displays captured data" do
      sentry_details = consumer.send(:sentry_details, message, event_type)
      expect(sentry_details[:type]).to eq("Events::DecisionReviewUpdatedEvent")
      expect(sentry_details[:partition]).to eq(1)
      expect(sentry_details[:offset]).to eq(10)
      expect(sentry_details[:message_payload]).to eq({ "claim_id" => 345 })
    end
  end

  describe "#handle_event_creation" do
    it "initializes a new event with the correct type and state" do
      event = consumer.send(:handle_event_creation, message, event_type)
      expect(event.message_payload).to eq(payload.message)
      expect(event.type).to eq("Events::DecisionReviewUpdatedEvent")
      expect(event.state).to eq("not_started")
    end
  end
end
