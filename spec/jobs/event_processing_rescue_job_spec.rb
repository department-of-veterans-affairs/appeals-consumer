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
        allow(Rails.logger)
          .to receive(:info)
        subject.perform
        expect(stuck_audit.reload.status).not_to eq("cancelled")
        expect(Rails.logger)
          .to have_received(:info)
          .with("[EventProcessingRescueJob] Time limit exceeded, stopping job execution.")
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
          expect { subject.send(:process_audit, stuck_audit) }.not_to raise_error
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
          expect { subject.send(:handle_reenqueue, event) }.not_to raise_error
        end
      end

      context "the determine_job return 'nil'" do
        it "logs an error" do
          allow(event).to receive(:determine_job).and_return(nil)
          expect(Rails.logger)
            .to receive(:error)
            .with(/\[EventProcessingRescueJob\] Failed to re-enqueue job for Event:/)
          subject.send(:handle_reenqueue, event)
        end
      end
    end

    describe "#_extra_details" do
      let(:event) { create(:event) }
      let(:audit) { create(:event_audit, event: event) }
      let(:error) { StandardError.new("Test error message") }

      it "return an empty hash when no parameters are provided" do
        expect(subject.send(:extra_details)).to eq({})
      end

      it "returns a hash with audit_id when only the audit is provided" do
        result = subject.send(:extra_details, audit: audit)
        expect(result).to eq({ event_audit_id: audit.id })
      end

      it "returns a hash with event_id and type when only the event is provided" do
        result = subject.send(:extra_details, event: event)
        expect(result).to eq({ event_id: event.id, type: event.type })
      end

      it "returns a hash with error message when only the error is provided" do
        result = subject.send(:extra_details, error: error)
        expect(result).to eq({ error_message: error.message })
      end

      it "returns a hash with all details when all parameters are provided" do
        result = subject.send(:extra_details, audit: audit, event: event, error: error)
        expect(result).to eq({
                               event_audit_id: audit.id,
                               event_id: event.id,
                               type: event.type,
                               error_message: error.message
                             })
      end
    end
  end
end