# frozen_string_literal: true

RSpec.describe BaseEventProcessingJob, type: :job do
  let(:event) { create(:event) }
  let(:job) { described_class.new }

  before do
    allow(RequestStore).to receive(:store).and_return({})
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CSS_ID").and_return("system_admin_css_id")
    allow(ENV).to receive(:[]).with("STATION_ID").and_return("system_admin_station_id")
    allow(ENV).to receive(:[]).with("MAX_ERRORS_FOR_FAILURE").and_return(3)
  end

  describe "#perform" do
    subject { job.perform(event) }

    before do
      allow_any_instance_of(Event).to receive(:process!).and_return(true)
    end

    context "when the job completes successfully" do
      it "processes the event and updates the event audit" do
        subject
        expect(event.reload.state).to eq("processed")
        expect(EventAudit.last.ended_at).not_to be_nil
        expect(EventAudit.last.status).to eq("completed")
      end
    end

    context "when the job encounters an error" do
      context "outside of a transaction block" do
        before do
          allow(Rails.logger).to receive(:error)
          allow_any_instance_of(Event).to receive(:process!).and_raise(StandardError.new)
          subject
        end

        it "handles the error and logs a message" do
          expect { subject.not_to raise_error }
          expect(Rails.logger)
            .to have_received(:error)
            .with(/An error has occured while processing a job for the event with event_id/)
          expect(EventAudit.last.status).to eq("failed")
          expect(EventAudit.last.ended_at).not_to be_nil
        end

        context "when the number of event audits is less than MAX_ERRORS_FOR_FAILURE" do
          it "updates the state of the event to 'error'" do
            expect(event.state).to eq("error")
          end
        end

        context "when the number of event audits is greater than or equal to MAX_ERRORS_FOR_FAILURE" do
          it "updates the state of the event to 'error'" do
            create_list(:event_audit, 3, event: event, error: "error msg")
            job.perform(event)

            expect(event.reload.state).to eq("failed")
          end
        end
      end

      context "within the start processing transaction" do
        let!(:audit_count) { event.event_audits.count }

        it "rollsback the transaction" do
          allow_any_instance_of(EventAudit).to receive(:started_at!).and_raise(StandardError.new)
          subject

          expect(event.event_audits.count).to eq(audit_count)
          expect(event.reload.state).not_to eq("in_progress")
        end
      end

      context "within the completed processing transaction" do
        it "rollsback the transaction" do
          allow_any_instance_of(EventAudit).to receive(:completed!).and_raise(StandardError.new)
          subject

          expect(event.event_audits.last.status).not_to eq("completed")
          expect(event.reload.state).not_to eq("processed")
        end
      end

      context "within the handle job error transaction" do
        it "rollsback the transaction" do
          allow_any_instance_of(Event).to receive(:process!).and_raise(StandardError.new)
          allow_any_instance_of(Event).to receive(:handle_failure).and_raise(StandardError.new)
          expect { subject }.to raise_error(StandardError)

          expect(event.event_audits.last.status).not_to eq("failed")
          expect(event.reload.state).not_to eq("error")
        end
      end
    end
  end
end