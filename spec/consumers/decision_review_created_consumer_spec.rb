# frozen_string_literal: true

describe DecisionReviewCreatedConsumer do
  let(:consumer) { described_class.new }
  let(:message) { instance_double("Message", payload: payload, metadata: metadata) }
  let(:payload) { double("Payload", message: { "claim_id" => 123 }, writer_schema: writer_schema) }
  let(:metadata) { double("Metadata", offset: 10, partition: 1) }
  let(:writer_schema) { double(fullname: "SchemaName") }
  let(:extra_details) do
    { partition: metadata.partition, offset: metadata.offset, claim_id: payload.message["claim_id"] }
  end

  describe "#consume" do
    let(:event) { double("Event", new_record?: new_record, id: 1) }
    let(:new_record) { true }

    before do
      allow(consumer).to receive(:messages).and_return([message])
      allow(Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent)
        .to receive(:find_or_initialize_by)
        .with(partition: metadata.partition, offset: metadata.offset)
        .and_return(event)
    end

    context "when event is a new record" do
      it "saves the even and performs DecisionReviewCreatedJob" do
        expect(event).to receive(:save)
        expect(DecisionReviewCreatedJob).to receive(:perform_later).with(event)
        consumer.consume
      end
    end

    context "when event is not a new record" do
      let(:new_record) { false }

      it "does not perform DecisionReviewCreatedJob" do
        expect(DecisionReviewCreatedJob).not_to receive(:perform_later)
        consumer.consume
      end
    end

    context "when ActiveRecord::RecordInvalid is raised" do
      before do
        allow(event).to receive(:save).and_raise(ActiveRecord::RecordInvalid)
      end

      it "handles the error" do
        expect(consumer).to receive(:handle_error).with(instance_of(ActiveRecord::RecordInvalid), extra_details)
        consumer.consume
      end
    end
  end

  describe "#handle_event_creation" do
    it "initializes a new event with the correct type and state" do
      event = consumer.send(:handle_event_creation, message)
      expect(event.message_payload).to eq(payload.message)
      expect(event.type).to eq(DecisionReviewCreatedConsumer::EVENT_TYPE)
      expect(event.state).to eq("not_started")
    end
  end
end
