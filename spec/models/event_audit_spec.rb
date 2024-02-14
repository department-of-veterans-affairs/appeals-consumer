# frozen_string_literal: true

RSpec.describe EventAudit, type: :model do
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
end
