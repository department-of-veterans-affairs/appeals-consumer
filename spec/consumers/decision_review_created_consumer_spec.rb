# frozen_string_literal: true

describe DecisionReviewCreatedConsumer do
  let(:consumer) { described_class.new }

  describe "#consume" do
    let(:message) { instance_double("Message", payload: payload, metadata: metadata) }
    let(:payload) { double("Payload", message: message_content) }
    let(:metadata) { double("Metadata", offset: 10, partition: 1) }
    let(:message_content) { { "claim_id" => 123 } }
    let(:event) { double("Event", new_record?: new_record) }
    let(:new_record) { true }

    before do
      allow(consumer).to receive(:messages).and_return([message])
      allow(Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent)
        .to receive(:find_or_initialize_by)
        .and_return(event)
    end

    context "when event is a new record" do
      it "saves the even and performs DecisionReviewCreateJob" do
        expect(event).to receive(:save)
        expect(DecisionReviewCreatedJob).to receive(:perform_later).with(event)
        consumer.consume
      end
    end

    context "when event is not a new record" do
      let(:new_record) { false }

      it "does not perform DecisionReviewCreateJob" do
        expect(DecisionReviewCreatedJob).not_to receive(:perform_later)
        consumer.consume
      end
    end

    context "when ActiveRecord::RecordInvalid is raised" do
      before do
        allow(event).to receive(:save).and_raise(ActiveRecord::RecordInvalid)
      end

      it "handles the error" do
        expect(consumer).to receive(:handle_error).with(instance_of(ActiveRecord::RecordInvalid), message)
        consumer.consume
      end
    end
  end

  describe "#handle_event_creation" do
    let(:message) { double(message: message_content, writer_schema: writer_schema) }
    let(:message_content) { { "claim_id" => 123 } }
    let(:writer_schema) { double(fullname: "SchemaName") }

    it "initializes a new event with the correct type ans status" do
      event = consumer.send(:handle_event_creation, message)
      expect(event).to be_a(Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent)
      expect(event.message_payload).to eq(message.message)
      expect(event.type).to eq("SchemaName")
      # expect(event.status).to eq(DecisionReviewCreatedConsumer::NOT_STARTED_STATUS)
    end
  end

  describe "#handle_error" do
    let(:error) { ActiveRecord::RecordInvalid.new }
    let(:message) { double("Message") }

    it "calls notify_sentry and notify_slack" do
      allow(consumer).to receive(:notify_sentry)
      allow(consumer).to receive(:notify_slack)

      consumer.send(:handle_error, error, message)

      expect(consumer).to have_received(:notify_sentry).with(error, message)
      expect(consumer).to have_received(:notify_slack)
    end
  end

  describe "#notify_sentry" do
    let(:error) { StandardError.new }
    let(:message) { double("Message", payload: double("Message", message: { claim_id: 123 }), metadata: metadata) }
    let(:metadata) { double("Metadata", offset: 10, partition: 1) }
    expected_extras = {
      claim_id: 123,
      source: DecisionReviewCreatedConsumer::CONSUMER_NAME,
      offset: 10,
      partition: 1
    }

    before do
      allow(Sentry).to receive(:capture_exception)
    end

    it "sends an error report to Sentry" do
      consumer.send(:notify_sentry, error, message)
      expect(Sentry).to have_received(:capture_exception).with(error) do |&block|
        scope = Sentry::Scope.new
        block.call(scope)
        expect(scope.instance_variable_get(:@extra)).to include(expected_extras)
      end
    end
  end

  describe "#notify_slack" do
    let(:slack_service) { instance_double("SlackService") }

    before do
      allow(consumer).to receive(:slack_service).and_return(slack_service)
      allow(slack_service).to receive(:send_notification)
    end

    it "sends a notification to slack" do
      consumer.send(:notify_slack)
      expect(slack_service)
        .to have_received(:send_notification)
        .with(instance_of(String), "DecisionReviewCreatedConsumer")
    end
  end

  describe "#slack_url" do
    it "returns the Slack URL from environment variables" do
      allow(ENV).to receive(:[]).with("SLACK_DISPATCH_ALERT_URL").and_return("http://example.com")
      expect(consumer.send(:slack_url)).to eq("http://example.com")
    end
  end

  describe "#slack_service" do
    before do

      allow(ENV).to receive(:[]).with("SLACK_DISPATCH_ALERT_URL").and_return("http://example.com")
      allow(ENV).to receive(:[]).with("DEPLOY_ENV").and_return("development")
    end

    it "returns a SlackService instance" do
      expect(consumer.send(:slack_service)).to be_a(SlackService)
    end

    it "memoizes the SlackService instance" do
      first_instance = consumer.send(:slack_service)
      expect(consumer.send(:slack_service)).to be(first_instance)
    end
  end
end
