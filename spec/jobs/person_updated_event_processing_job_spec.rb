# frozen_string_literal: true

RSpec.describe PersonUpdatedEventProcessingJob, type: :job do
  include ActiveJob::TestHelper
  let!(:event) { create(:person_updated_event) }

  describe "#perform_now(event)" do
    subject { PersonUpdatedEventProcessingJob.perform_now(event) }

    before do
      allow(event).to receive(:process!)
    end

    it "calls PersonUpdatedEventProcessingJob.process!(event) immediately and does not raise an error" do
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
      job_name = /\[PersonUpdatedEventProcessingJob\]/
      error_message = /An error has occured while processing a job for the event with event_id/

      expect { described_class.perform_now(event) }.to raise_error(StandardError, "test error")
      expect(Rails.logger)
        .to have_received(:error)
        .with(/#{job_name} #{error_message}/)
    end
  end

  describe "#perform_later(event)" do
    subject { PersonUpdatedEventProcessingJob.perform_later(event) }

    it "enqueues the job with the event as an argument" do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }
        .to have_enqueued_job(PersonUpdatedEventProcessingJob)
        .with(event)
        .on_queue("appeals_consumer"\
        "_development_high_priority")
    end

    it "does not raise an error" do
      expect { subject }.not_to raise_error
    end
  end
end
