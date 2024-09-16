# frozen_string_literal: true

RSpec.describe DecisionReviewCreatedEventProcessingJob, type: :job do
  include ActiveJob::TestHelper
  let!(:event) { create(:decision_review_created_event) }

  describe "#perform_now(event)" do
    subject { DecisionReviewCreatedEventProcessingJob.perform_now(event) }

    before do
      allow(event).to receive(:process!)
    end

    it "calls DecisionReviewCreatedEventProcessingJob.process!(event) immediately and does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end

  context "when an error occurs" do
    let(:error) { StandardError.new("test error") }

    before do
      allow(event).to receive(:process!).and_raise(error)
      allow(Rails.logger).to receive(:error)
    end

    it "logs the error" do
      expect { described_class.perform_now(event) }.to raise_error(StandardError, "test error")
      expect(Rails.logger)
        .to have_received(:error)
        .with(/An error has occured while processing a job for the event with event_id/)
    end
  end

  describe "#perform_later(event)" do
    subject { DecisionReviewCreatedEventProcessingJob.perform_later(event) }

    it "enqueues the job with the event as an argument" do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }
        .to have_enqueued_job(DecisionReviewCreatedEventProcessingJob)
        .with(event)
        .on_queue("appeals_consumer"\
          "_development_high_priority")
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end
end
