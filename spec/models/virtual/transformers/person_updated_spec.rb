# frozen_string_literal: true

describe Transformers::PersonUpdated do
  # Line 5 is the example for line 6 but passing in the person_updated_event factory
  # subject(:decision_review_updated) { described_class.new(event_id, message_payload) }
  subject(:person_updated) { described_class.new(event_id, person_updated_event) }
  let(:person_updated_event) do
    create(:event, type: "Events::PersonUpdatedEvent")
  end
  let(:event_id) { 13 }

  # let(:event_id) { person_updated_event.id }

  context "when valid" do
    describe "#initialize" do
      it "sets the event id" do
        expect(person_updated.event_id).to eq(13)
      end

      it "validates the message_payload" do
        expect { person_updated }.not_to raise_error
      end

      it "sets the instance variables for PersonUpdated" do
        expect(subject.participant_id).to eq(person_updated_event["participant_id"])
        expect(subject.name_suffix).to eq(person_updated_event["name_suffix"])
        expect(subject.ssn).to eq(person_updated_event["ssn"])
        expect(subject.first_name).to eq(person_updated_event["first_name"])
        expect(subject.middle_name).to eq(person_updated_event["middle_name"])
        expect(subject.last_name).to eq(person_updated_event["last_name"])
        expect(subject.email_address).to eq(person_updated_event["email_address"])
        expect(subject.date_of_birth).to eq(person_updated_event["date_of_birth"])
        expect(subject.date_of_death).to eq(person_updated_event["date_of_death"])
        expect(subject.file_number).to eq(person_updated_event["file_number"])
        expect(subject.is_veteran).to eq(person_updated_event["is_veteran"])
        expect(subject.person_updated.size).to eq(
          person_updated_event["person_updated"].count
        )
      end

      it "instantiates a PersonUpdated object" do
        subject.person_updated.each do |person|
          expect(person).to be_an_instance_of(PersonUpdated)
        end
      end
    end
  end
end
