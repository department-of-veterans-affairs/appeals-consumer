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

      context "updating audit notes" do
        let(:cancelled_note) do
          "EventAudit was left in an uncompleted state for longer "\
          "than 26 minutes and was marked as \"CANCELLED\" at #{Time.zone.now}."
        end
        let(:new_audit_notes) do
          "test note - #{cancelled_note}"
        end

        before do
          Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
        end

        context "when the audit has an existing note" do
          let!(:stuck_audit_with_notes) do
            create(:event_audit, :stuck, event: event, notes: "test note")
          end

          it "updates the audit's notes with new cancelled message" do
            expect { EventProcessingRescueJob.perform_now }
              .to change { stuck_audit_with_notes.reload.notes }.from("test note").to(new_audit_notes)
          end
        end

        context "when the audit does not have an existing note" do
          it "updates the audit's notes with existing message concatenated with new cancelled message" do
            expect { EventProcessingRescueJob.perform_now }
              .to change { stuck_audit.reload.notes }.from(nil).to(cancelled_note)
          end
        end
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
          .with(/Time limit exceeded, stopping job execution./)
      end
    end

    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:emit_gauge)
      EventProcessingRescueJob.perform_now
    end
  end

  describe "rescue_from StandardError" do
    it "logs an error and handles the exception" do
      allow(EventAudit).to receive(:stuck).and_raise(StandardError)
      expect(Rails.logger)
        .to receive(:error)
        .with(/Encountered an exception./)
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
            .with(/Failed to process EventAudit./)
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
            .with(/Error during the re-enqueue for Event./)
          expect { subject.send(:handle_reenqueue, event) }.not_to raise_error
        end
      end

      context "the determine_job return 'nil'" do
        it "logs an error" do
          allow(event).to receive(:determine_job).and_return(nil)
          expect(Rails.logger)
            .to receive(:error)
            .with(/Failed to re-enqueue job for Event./)
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

    describe "#_audit_concatenated_notes(msg)" do
      let(:msg) do
        "EventAudit was left in an uncompleted state for longer "\
        "than 26 minutes and was marked as \"CANCELLED\" at #{Time.zone.now}."
      end
      let!(:event) { create(:decision_review_created_event) }
      subject { described_class.new.send(:audit_concatenated_notes, audit) }

      before do
        Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
      end

      context "when the audit record has not-nil value for notes" do
        let!(:audit) { create(:event_audit, :stuck, notes: "test note", event: event) }
        it "updates the audit with existing message concatenates with new cancelled message" do
          expect(subject).to eq("test note - #{msg}")
        end
      end

      context "when the audit record has nil value for notes" do
        let!(:audit) { create(:event_audit, :stuck, event: event) }
        it "updates the audit with new cancelled message" do
          expect(subject).to eq(msg)
        end
      end
    end
  end
end
