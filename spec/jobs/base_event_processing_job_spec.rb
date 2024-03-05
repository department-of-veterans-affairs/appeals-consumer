# frozen_string_literal: true

RSpec.describe BaseEventProcessingJob, type: :job do
  let!(:event) { create(:event) }
  let(:job) { described_class.new }

  before do
    allow(RequestStore).to receive(:store).and_return({})
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("CSS_ID").and_return("system_admin_css_id")
    allow(ENV).to receive(:[]).with("STATION_ID").and_return("system_admin_station_id")
  end

  describe "#perform" do
    context "when the job completes successfully" do
      before do
        allow(event).to receive(:process!).and_return(true)
        job.perform(event)
      end

      it "processes the event and updates the event audit" do
        expect(event.reload.state).to eq("processed")
        expect(EventAudit.last.ended_at).not_to be_nil
        expect(EventAudit.last.status).to eq("completed")
      end
    end

    context "when the job encounters an error" do
      subject { job.perform(event) }

      before do
        allow(event).to receive(:process!).and_raise(StandardError.new)
        allow(Rails.logger).to receive(:error)
        subject
      end

      it "handles the error and logs a message" do
        expect { subject.not_to raise_error }
        expect(Rails.logger)
          .to have_received(:error)
          .with(/An error has occured while processing a job for the event with event_id/)
        expect(event.reload.state).to eq("error")
        expect(EventAudit.last.status).to eq("failed")
        expect(EventAudit.last.ended_at).not_to be_nil
      end
    end
  end
end
