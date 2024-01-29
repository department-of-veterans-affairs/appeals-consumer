# frozen_string_literal: true

RSpec.describe AvroLoggerService, type: :service do
  subject { AvroLoggerService.new($stderr) }

  describe "hard coded constants are set correctly" do
    it "should have ERROR_MSG set correctly" do
      expect(subject.class::ERROR_MSG).to eq "Error running AvroDeserializerService"
    end

    it "should have SERVICE_NAME set correctly" do
      expect(subject.class::SERVICE_NAME).to eq "AvroDeserializerService"
    end
  end

  describe "#methods" do
    let(:error) { StandardError.new }

    describe "#error" do
      it "should report an error with no block given" do
        expect(subject).to receive(:report_error).with(error)

        subject.error(error)
      end

      it "should report an error with a block given" do
        expect(subject).to receive(:report_error) { "yielding a block" }

        subject.error(error)
      end
    end

    describe "#report_error" do
      it "should call notify_sentry and notify_slack" do
        expect(subject).to receive(:notify_sentry).with(error)
        expect(subject).to receive(:notify_slack)
        subject.error(error)
      end
    end

    describe "#_notify_slack" do
      it "should send a slack notification" do
        expect(subject.send(:slack_service)).to receive(:send_notification)
        subject.send(:notify_slack)
      end
    end

    describe "#_notify_sentry" do
      let(:sentry_scope) { Sentry.get_current_hub.current_scope }

      before do
        allow(Sentry).to receive(:capture_exception)
      end

      it "should notify sentry" do
        expect(subject.send(:notify_sentry, error))
        expect(Sentry).to have_received(:capture_exception).with(error) do |&block|
          block.call(sentry_scope)
        end
        expect(sentry_scope.instance_variable_get(:@extra)).to include({ source: subject.class::SERVICE_NAME })
      end
    end

    describe "#_slack_url" do
      it "should return the SLACK_DISPATCH_ALERT_URL" do
        ClimateControl.modify SLACK_DISPATCH_ALERT_URL: "http://localhost" do
          expect(subject.send(:slack_url)).to eq "http://localhost"
        end
      end
    end

    describe "#_slack_service" do
      it "should return a new slack_service" do
        expect(subject.send(:slack_service)).to be_instance_of(SlackService)
      end
    end
  end
end
