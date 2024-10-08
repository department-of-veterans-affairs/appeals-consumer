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
      # not sure how to check for the veteran indicator
    end
  end
end
