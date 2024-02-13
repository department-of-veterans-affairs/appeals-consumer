# frozen_string_literal: true

describe ApplicationConsumer do
  let(:consumer) { described_class.new }

  describe "#handle_error" do
    let(:error) { ActiveRecord::RecordInvalid.new }
    let(:error_message) { double("Message") }

    before do
      allow(consumer).to receive(:notify_sentry)
      allow(consumer).to receive(:notify_slack)
    end

    it "calls notify_sentry and notify_slack" do
      consumer.send(:handle_error, error, error_message)
      expect(consumer).to have_received(:notify_sentry).with(error, error_message)
      expect(consumer).to have_received(:notify_slack)
    end
  end

  describe "#notify_sentry" do
    let(:error) { StandardError.new }
    let(:sentry_scope) { Sentry.get_current_hub.current_scope }
    let(:extra_details) do
      {
        claim_id: 123,
        source: "ApplicationConsumer",
        offset: 10,
        partition: 1
      }
    end

    before do
      allow(Sentry).to receive(:capture_exception)
    end

    it "sends an error report to Sentry with correct extras" do
      consumer.send(:notify_sentry, error, extra_details)
      expect(Sentry).to have_received(:capture_exception).with(error) do |&block|
        block.call(sentry_scope)
      end
      expect(sentry_scope.instance_variable_get(:@extra)).to include(extra_details)
    end
  end

  describe "#notify_slack" do
    let(:slack_service) { instance_double("SlackService") }

    before do
      allow(consumer).to receive(:slack_service).and_return(slack_service)
      allow(slack_service).to receive(:send_notification)
    end

    it "sends a notification to Slack" do
      consumer.send(:notify_slack)
      expect(slack_service)
        .to have_received(:send_notification)
        .with(instance_of(String), "ApplicationConsumer")
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
