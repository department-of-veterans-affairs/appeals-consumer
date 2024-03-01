# frozen_string_literal: true

RSpec.describe DecisionReviewCreatedEventProcessingJob, type: :job do
  let!(:event) { create(:event) }

  describe "#perform_now(event)" do
    subject { DecisionReviewCreatedEventProcessingJob.perform_now(event) }

    it "calls DecisionReviewCreatedEventProcessingJob.process!(event) immediately" do
      expect(event).to receive(:process!)
      subject
    end

    it "does not raise an error" do
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
      described_class.perform_now(event)
      expect(Rails.logger).to have_received(:error).with(error)
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
