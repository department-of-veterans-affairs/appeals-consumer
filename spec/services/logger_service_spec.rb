# frozen_string_literal: true

describe LoggerService do
  let(:caller_class) { "SomeClass" }
  let(:service) { LoggerService.new(caller_class) }
  let(:message) { "Test message" }
  let(:extra) { { key: "value" } }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
    allow(Rails.logger).to receive(:warn)
  end

  describe "#info" do
    it "logs an informational message" do
      service.info(message, extra)

      expect(Rails.logger).to have_received(:info).with(/\[#{caller_class}\] #{message} | #{extra.to_json}/)
    end
  end

  describe "#error" do
    it "logs an error message" do
      service.error(message, extra)

      expect(Rails.logger).to have_received(:error).with(/\[#{caller_class}\] #{message} | #{extra.to_json}/)
    end

    it "notifies Sentry and Slack on alert" do
      allow(service).to receive(:notify_error)
      service.error(message, extra, notify_alerts: true)

      expect(service).to have_received(:notify_error).with(message, extra)
    end
  end

  describe "#warn" do
    it "logs an warning message" do
      service.warn(message, extra)

      expect(Rails.logger).to have_received(:warn).with(/\[#{caller_class}\] #{message} | #{extra.to_json}/)
    end
  end
  context "Private methods" do
    describe "#_notify_error" do
      let(:error) { ActiveRecord::RecordInvalid.new }
      let(:error_message) { double("Message") }

      before do
        allow(service).to receive(:notify_sentry)
        allow(service).to receive(:notify_slack)
      end

      it "calls notify_sentry and notify_slack" do
        service.send(:notify_error, error, error_message)
        expect(service).to have_received(:notify_sentry).with(error, error_message)
        expect(service).to have_received(:notify_slack)
      end
    end

    describe "#_notify_sentry" do
      let(:error) { StandardError.new }
      let(:message) { "Test message" }
      let(:formatted_message) { "[#{caller_class}] #{message}" }
      let(:extra_details) do
        {
          claim_id: 123,
          source: caller_class,
          offset: 10,
          partition: 1,
          error: error
        }
      end

      before do
        allow(Raven).to receive(:capture_exception)
      end

      it "sends an error report to Sentry with correct extras" do
        service.send(:notify_sentry, message, extra_details)
        expect(Raven).to have_received(:capture_exception).with(error,
                                                                extra: { **extra_details, message: formatted_message })
      end
    end

    describe "#_notify_slack" do
      let(:slack_service) { instance_double("SlackService") }

      before do
        allow(service).to receive(:slack_service).and_return(slack_service)
        allow(slack_service).to receive(:send_notification)
      end

      it "sends a notification to Slack" do
        service.send(:notify_slack)
        expect(slack_service)
          .to have_received(:send_notification)
          .with(/\[#{caller_class}\] Error has occured./)
      end
    end

    describe "#_slack_url" do
      it "returns the Slack URL from environment variables" do
        allow(ENV).to receive(:[]).with("SLACK_DISPATCH_ALERT_URL").and_return("http://example.com")
        expect(service.send(:slack_url)).to eq("http://example.com")
      end
    end

    describe "#_slack_service" do
      before do
        allow(ENV).to receive(:[]).with("SLACK_DISPATCH_ALERT_URL").and_return("http://example.com")
        allow(ENV).to receive(:[]).with("DEPLOY_ENV").and_return("development")
      end

      it "returns a SlackService instance" do
        expect(service.send(:slack_service)).to be_a(SlackService)
      end

      it "memoizes the SlackService instance" do
        first_instance = service.send(:slack_service)
        expect(service.send(:slack_service)).to be(first_instance)
      end
    end
  end
end
