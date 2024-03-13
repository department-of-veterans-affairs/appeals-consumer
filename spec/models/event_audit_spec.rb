# frozen_string_literal: true

RSpec.describe EventAudit, type: :model do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  describe "#save" do
    let!(:my_event) { create(:event) }
    subject { EventAudit.new(event_id: nil) }

    it "should fail creating an event_audit with empty event_id" do
      expect(subject.valid?).to eq false
      expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "should fail creating an event_audit with incorrect status" do
      subject.event_id = my_event.id
      expect(subject.valid?).to eq true
      expect { subject.status = "some_random_status" }.to raise_error(ArgumentError)
      subject.save!
      expect(subject.status).to eq "in_progress"
    end

    it "should have a default status of 'in_progress'" do
      expect(subject.status).to eq "in_progress"
    end
  end

  describe "#event" do
    let!(:my_event) { create(:event) }
    let!(:my_event_audit) { create(:event_audit, event: my_event) }

    it "should associate with it's event" do
      expect(my_event.event_audits.first).to eq my_event_audit
    end

    it "should have event that have a bi-directional relationship with itself" do
      expect(my_event.event_audits.first.id).to eq my_event_audit.id
    end
  end

  describe "#in_progress!" do
    it "updates the state to in_progress" do
      event_audit = create(:event_audit)
      event_audit.in_progress!
      expect(event_audit.reload.status).to eq("in_progress")
    end
  end

  describe "#completed!" do
    it "updates the state to completed" do
      event_audit = create(:event_audit)
      event_audit.completed!
      expect(event_audit.reload.status).to eq("completed")
    end
  end

  describe "#failed!" do
    let(:error_message) { "test error message" }

    it "updates the state to failed" do
      event_audit = create(:event_audit)
      event_audit.failed!(error_message)
      expect(event_audit.reload.status).to eq("failed")
      expect(event_audit.reload.error).to eq(error_message)
    end
  end

  describe "#started_at!" do
    it "updates the started_at to the correct time" do
      event_audit = create(:event_audit)
      event_audit.started_at!
      expect(event_audit.reload.started_at).to eq(Time.now.utc)
    end
  end

  describe "#ended_at!" do
    it "updates the ended_at to the correct time" do
      event_audit = create(:event_audit)
      event_audit.ended_at!
      expect(event_audit.reload.ended_at).to eq(Time.now.utc)
    end
  end
end
