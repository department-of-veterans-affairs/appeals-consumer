# frozen_string_literal: true

RSpec.describe DecisionReviewCreatedJob, type: :job do
  let!(:event) { create(:event) }

  describe "#perform_now(event)" do
    subject { DecisionReviewCreatedJob.perform_now(event) }

    it "calls DecisionReviewCreatedEvent.process!(event) immediately" do
      expect(Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent).to receive(:process!).with(event)
      subject
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end

  describe "#perform_later(event)" do
    subject { DecisionReviewCreatedJob.perform_later(event) }

    it "enqueues the job with the event as an argument" do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }.to have_enqueued_job(DecisionReviewCreatedJob).with(event).on_queue("appeals_consumer"\
        "_development_high_priority")
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end
end
