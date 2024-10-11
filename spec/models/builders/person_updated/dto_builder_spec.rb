# frozen_string_literal: true

describe Builders::PersonUpdated::DtoBuilder do
  # the event will fail as it is not built out yet
  # let!(:event) { create(:person_updated_event, message_payload: person_updated_model.to_json) }
  # let(:person_updated_model) { build(:perso_updated) }
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

  describe "initialize" do
    # it "should return a PersonUpdated object with response and pii attributes(not in payload)" do
    #   allow_any_instance_of(Builders::PersonUpdated::DtoBuilder).to receive(:build_decision_review_created)
    #     .with(JSON.parse(drc_event.message_payload)).and_return(drc)
    #   allow_any_instance_of(Builders::DecisionReviewCreated::DtoBuilder).to receive(:assign_attributes)
    #   expect(Builders::DecisionReviewCreated::DtoBuilder.new(drc_event)).to have_received(:assign_attributes)
    #   expect(Builders::DecisionReviewCreated::DtoBuilder.new(drc_event))
    #     .to be_instance_of(Builders::DecisionReviewCreated::DtoBuilder)
    # end

    it "assigns @#person_updated_model for person" do
      expect(builder.person_updated_model).to eq(person_updated_model)
    end

    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:emit_gauge)
      Builders::PersonUpdated::DtoBuilder.new(person_updated_model)
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
      expect(person.file_number).to eq(person_updated_model.file_number)
      expect(person.is_veteran).to eq(person_updated_model.is_veteran)
    end
  end
end
