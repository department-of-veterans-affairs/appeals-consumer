# frozen_string_literal: true

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  let(:person_updated_event) do
    create(:person_updated_event, type: "Events::PersonUpdatedEvent")
  end

  let(:dto_builder) { described_class.new(person_updated_event) }
  let(:event_id) { person_updated_event.id }
  let(:person) { described_class.new(person) }

  describe "initialize" do
    it "calls MetricsService to record metrics" do
      expect(MetricsService).to receive(:record).with(
        "Build person updated #{person_updated_event}",
        service: :dto_builder,
        name: "Builders::PersonUpdated::DtoBuilder.initialize"
      ).and_call_original

      dto_builder
    end

    it "initializes instance variables" do
      expect(dto_builder.instance_variable_get(:@event_id)).to be_a(Integer)
      expect(dto_builder.instance_variable_get(:@person_updated)).to be_a(Transformers::PersonUpdated)
      expect(dto_builder.instance_variable_get(:@person)).to be_a(BasePerson)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attributes" do
      expect(dto_builder.instance_variable_get(:@person_updated).first_name).to eq(
        dto_builder.instance_variable_get(:@person).first_name
      )
      expect(dto_builder.instance_variable_get(:@person_updated).last_name).to eq(
        dto_builder.instance_variable_get(:@person).last_name
      )
      expect(dto_builder.instance_variable_get(:@person_updated).middle_name).to eq(
        dto_builder.instance_variable_get(:@person).middle_name
      )
      expect(dto_builder.instance_variable_get(:@person_updated).name_suffix).to eq(
        dto_builder.instance_variable_get(:@person).name_suffix
      )
      expect(dto_builder.instance_variable_get(:@person_updated).participant_id).to eq(
        dto_builder.instance_variable_get(:@person).participant_id
      )
      expect(dto_builder.instance_variable_get(:@person_updated).ssn).to eq(
        dto_builder.instance_variable_get(:@person).ssn
      )
      expect(dto_builder.instance_variable_get(:@person_updated).date_of_birth).to eq(
        dto_builder.instance_variable_get(:@person).date_of_birth
      )
      expect(dto_builder.instance_variable_get(:@person_updated).email_address).to eq(
        dto_builder.instance_variable_get(:@person).email_address
      )
      expect(dto_builder.instance_variable_get(:@person_updated).date_of_death).to eq(
        dto_builder.instance_variable_get(:@person).date_of_death
      )
      expect(dto_builder.instance_variable_get(:@person_updated).file_number).to eq(
        dto_builder.instance_variable_get(:@person).file_number
      )
      expect(dto_builder.instance_variable_get(:@person_updated).is_veteran).to eq(
        dto_builder.instance_variable_get(:@person).is_veteran
      )
    end
  end
end
