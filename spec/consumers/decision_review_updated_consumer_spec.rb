# frozen_string_literal: true

describe DecisionReviewUpdatedConsumer do
  let(:consumer) { described_class.new }
  let(:message) { instance_double("Message", payload: payload, metadata: metadata) }
  let(:payload) { double("Payload", message: { "claim_id" => 123 }, writer_schema: writer_schema) }
  let(:metadata) { double("Metadata", offset: 10, partition: 1) }
  let(:writer_schema) { double(fullname: "SchemaName") }
  let(:extra_details) do
    {
      partition: metadata.partition,
      offset: metadata.offset,
      claim_id: payload.message["claim_id"],
      type: described_class::EVENT_TYPE
    }
  end

  describe "#consume" do
    let(:event) { double("Event", new_record?: new_record, id: 1) }
    let(:new_record) { true }
    consumer_name = /\[DecisionReviewUpdatedConsumer\]/

    before do
      allow(consumer).to receive(:messages).and_return([message])
      allow(Events::DecisionReviewUpdatedEvent)
        .to receive(:find_or_initialize_by)
        .with(partition: metadata.partition, offset: metadata.offset)
        .and_return(event)
    end

    context "when event is a new record" do
      it "saves the event, performs DecisionReviewUpdatedEventProcessingJob, and calls MetricsService.record" do
        expect(event).to receive(:save)
        expect(DecisionReviewUpdatedEventProcessingJob).to receive(:perform_later).with(event)
        # The following expects are for MetricsService being used inside consume
        expect(Rails.logger).to receive(:info).with(a_string_starting_with("STARTED"))
        expect(Rails.logger).to receive(:info).with(a_string_starting_with("FINISHED"))
        expect(MetricsService).to receive(:emit_gauge)
        # End of MetricsService specific expects
        expect(Karafka.logger).to receive(:info).with(/Starting consumption/)
        expect(Karafka.logger).to receive(:info).with(/#{consumer_name} Dropped Event into processing job/)
        expect(Karafka.logger).to receive(:info).with(/Completed consumption of message/)
        consumer.consume
      end
    end

    context "when event is not a new record" do
      let(:new_record) { false }
      logger_message = /Event record already exists. Skipping enqueueing job/

      it "does not perform DecisionReviewUpdatedEventProcessingJob, and calls MetricsService to record metrics" do
        expect(DecisionReviewUpdatedEventProcessingJob).not_to receive(:perform_later)
        # The following expects are for MetricsService being used inside consume
        expect(Rails.logger).to receive(:info).with(a_string_starting_with("STARTED"))
        expect(Rails.logger).to receive(:info).with(a_string_starting_with("FINISHED"))
        expect(MetricsService).to receive(:emit_gauge)
        # End of MetricsService specific expects
        expect(Karafka.logger).to receive(:info).with(/Starting consumption/)
        expect(Karafka.logger).to receive(:info).with(/#{consumer_name} #{logger_message}/)
        expect(Karafka.logger).to receive(:info).with(/Completed consumption of message/)
        consumer.consume
      end
    end

    context "when ActiveRecord::RecordInvalid is raised" do
      before do
        allow(event).to receive(:save).and_raise(ActiveRecord::RecordInvalid)
      end

      context "while the message has been attempted 3 times or less" do
        it "raises an error" do
          allow(consumer).to receive(:attempt).and_return(1)
          expect { consumer.consume }.to raise_error(AppealsConsumer::Error::EventConsumptionError)
        end
      end

      context "while the message has been attempted more than 3 times" do
        before do
          allow(consumer).to receive(:attempt).and_return(4)
        end
        it "logs sentry and slack" do
          expect_any_instance_of(LoggerService).to receive(:notify_sentry)
          expect_any_instance_of(LoggerService).to receive(:notify_slack)
          consumer.consume
        end

        it "handles the error" do
          expect { consumer.consume }.not_to raise_error
        end
      end
    end
  end

  describe "#handle_event_creation" do
    it "initializes a new event with the correct type and state" do
      event = consumer.send(:handle_event_creation, message)
      expect(event.message_payload).to eq(payload.message)
      expect(event.type).to eq(DecisionReviewUpdatedConsumer::EVENT_TYPE)
      expect(event.state).to eq("not_started")
    end
  end
end