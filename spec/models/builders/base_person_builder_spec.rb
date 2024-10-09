# frozen_string_literal: true

describe Builders::BasePersonBuilder do
  # the event will fail as it is not built out yet
  # let!(:event) { create(:person_updated_event, message_payload: person_updated_model.to_json) }
  # let!(:event_id) { event.id }
  let!(:person_updated_model) { build(:person) }
  let(:builder) { described_class.new(person_updated_model) }
  let(:person) { described_class.build(person_updated_model) }

  # won't be able to do this until the event is created
  # before do
  #   person_updated_model.instance_variable_set(:@event_id, event_id)
  # end

  describe "#build" do
    it "returns a BasePerson object" do
      expect(person).to be_an_instance_of(BasePerson)
    end
  end

  describe "initialization" do
    it "assigns @#person_updated_model for person" do
      expect(builder.person_updated_model).to eq(person_updated_model)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attribbutes" do
      expect(person.first_name).to eq(person_updated_model.first_name)
      expect(person.last_name).to eq(person_updated_model.last_name)
      expect(person.middle_name).to eq(person_updated_model.middle_name)
      expect(person.name_suffix).to eq(person_updated_model.name_suffix)
      expect(person.participant_id).to eq(person_updated_model.participant_id)
      expect(person.ssn).to eq(person_updated_model.ssn)
      expect(person.date_of_birth).to eq(person_updated_model.date_of_birth)
      expect(person.email_address).to eq(person_updated_model.email_address)
      expect(person.date_of_death).to eq(person_updated_model.date_of_death)
      # not sure how to check for the veteran indicator
    end
  end

  # describe "fetching BIS record" do
  #   context "when the BIS record is not found" do
  #     let(:msg) do
  #       "BIS Person: Person record not found for DecisionReviewCreated person_participant_id:"\
  #       " #{decision_review_model.person_participant_id}"
  #     end
  #     let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }

  #     before do
  #       allow_any_instance_of(BISService).to receive(:fetch_person_info).and_return({})
  #       allow(Rails.logger).to receive(:info)
  #     end

  #     it "logs message" do
  #       expect(Rails.logger).to receive(:info).with(/#{msg}/)
  #       person
  #     end

  #     it "sets BIS fields to nil" do
  #       expect(person.name_suffix).to eq nil
  #       expect(person.ssn).to eq nil
  #       expect(person.date_of_birth).to eq nil
  #       expect(person.first_name).to eq nil
  #       expect(person.middle_name).to eq nil
  #       expect(person.last_name).to eq nil
  #       expect(person.email).to eq nil
  #     end

  #     context "when there is already a message in the event_audit's notes column" do
  #       let!(:event_audit_with_note) do
  #         create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
  #       end

  #       it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
  #         person
  #         expect(event_audit_with_note.reload.notes)
  #           .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{msg}")
  #       end
  #     end

  #     context "when there isn't a message in the event_audit's notes column" do
  #       it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
  #         person
  #         expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{msg}")
  #       end
  #     end
  # end
  # end
end
