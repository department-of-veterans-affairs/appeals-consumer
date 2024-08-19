# frozen_string_literal: true

describe HeartbeatJob do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  describe "#perform" do
    it "logs an informational message" do
      expect_any_instance_of(LoggerService).to receive(:info).with("This is a heartbeat ping")
      perform_enqueued_jobs { job }
    end

    context "when an error occurs" do
      it "logs the error" do
        allow_any_instance_of(LoggerService).to receive(:info).and_raise(StandardError, "Something went wrong")
        expect_any_instance_of(LoggerService).to receive(:error).with(instance_of(StandardError))
        perform_enqueued_jobs { job }
      end
    end
  end
end
