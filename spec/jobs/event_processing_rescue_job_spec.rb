# frozen_string_literal: true

describe EventProcessingRescueJob, type: :job do
  include ActiveJob::TestHelper

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe "#perform" do
    context "when the time limit has not been exceeded" do
      let!(:event) { create(:decision_review_created_event) }
      let!(:stuck_audit) do
        create(:event_audit, :stuck, event: event)
      end

      it "processes stuck audits" do
        expect { EventProcessingRescueJob.perform_now }
          .to change { stuck_audit.reload.status }.from("in_progress").to("cancelled")
          .and change { stuck_audit.reload.ended_at }.from(nil)
      end

      context "when the event is in an end state" do
        it "skips re-enqueueing the event" do
          allow_any_instance_of(Event).to receive(:end_state?).and_return(true)
          expect { EventProcessingRescueJob.perform_now }
            .not_to have_enqueued_job(DecisionReviewCreatedEventProcessingJob)
        end
      end

      context "when the event is not in an end state" do
        it "re-enqueues the specific event processing job" do
          allow_any_instance_of(Event).to receive(:end_state?).and_return(false)
          expect { EventProcessingRescueJob.perform_now }
            .to have_enqueued_job(DecisionReviewCreatedEventProcessingJob)
            .with(event)
        end
      end
    end

    context "when the time limit has been exceeded" do
      let!(:stuck_audit) do
        create(:event_audit, :stuck, event: create(:decision_review_created_event))
      end

      it "stops processing without handling all audits" do
        allow_any_instance_of(EventProcessingRescueJob).to receive(:time_exceeded?).and_return(true)
        expect(Rails.logger)
          .to receive(:info)
          .with("[EventProcessingRescueJob] Time limit exceeded, stopping job execution.")
        EventProcessingRescueJob.new.perform
        expect(stuck_audit.reload.status).not_to eq("cancelled")
      end
    end
  end

  describe "rescue_from StandardError" do
    it "logs an error and handles the exception" do
      allow(EventAudit).to receive(:stuck).and_raise(StandardError)
      expect(Rails.logger)
        .to receive(:error)
        .with(/\[EventProcessingRescueJob\] encountered an exception:/)
      expect { EventProcessingRescueJob.perform_now }.not_to raise_error
    end
  end

  describe "private methods" do
    let!(:event) { create(:decision_review_created_event) }
    let!(:stuck_audit) do
      create(:event_audit, :stuck, event: event)
    end

    describe "#_process_audit" do
      context "when an error is raised" do
        it "logs an error and handles the exception" do
          allow(stuck_audit).to receive(:cancelled!).and_raise(StandardError.new("Test Error"))
          expect(Rails.logger)
            .to receive(:error)
            .with(/\[EventProcessingRescueJob\] Failed to process audit/)
          expect { EventProcessingRescueJob.new.send(:process_audit, stuck_audit) }.not_to raise_error
        end
      end
    end

    describe "#_handle_reenqueue" do
      context "when an error is raised" do
        it "logs an error and handles the exception" do
          allow(event).to receive(:determine_job).and_raise(StandardError.new("Test Error"))
          expect(Rails.logger)
            .to receive(:error)
            .with(/\[EventProcessingRescueJob\] Error during the re-enqueue for event/)
          expect { EventProcessingRescueJob.new.send(:handle_reenqueue, event) }.not_to raise_error
        end
      end

      context "the determine_job return 'nil'" do
        it "logs an error" do
          allow(event).to receive(:determine_job).and_return(nil)
          expect(Rails.logger)
            .to receive(:error)
            .with(/\[EventProcessingRescueJob\] Failed to re-enqueue job for Event ID:/)
          EventProcessingRescueJob.new.send(:handle_reenqueue, event)
        end
      end
    end
  end
end
