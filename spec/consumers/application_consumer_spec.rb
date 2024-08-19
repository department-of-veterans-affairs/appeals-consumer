# frozen_string_literal: true

describe ApplicationConsumer do
  subject { ApplicationConsumer.new }
  let(:consumer) { described_class.new }

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
end
