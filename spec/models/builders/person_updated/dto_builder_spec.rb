# frozen_string_literal: true

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  let(:dto_builder) { described_class.new(person_updated_event) }
  let(:person_updated_event) do
    create(:event, type: "Events::PersonUpdatedEvent")
  end
  let(:event_id) { person_updated_event.id }

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
      expect(dto_builder.instance_variable_get(:@event_id)).to eq(event_id)
      expect(dto_builder.instance_variable_get(:@person_updated)).to be_a(Transformers::PersonUpdated)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attribbutes" do
      expect(dto_builder.first_name).to eq(person_updated_event.first_name)
      expect(dto_builder.last_name).to eq(person_updated_event.last_name)
      expect(dto_builder.middle_name).to eq(person_updated_event.middle_name)
      expect(dto_builder.name_suffix).to eq(person_updated_event.name_suffix)
      expect(dto_builder.participant_id).to eq(person_updated_event.participant_id)
      expect(dto_builder.ssn).to eq(person_updated_event.ssn)
      expect(dto_builder.date_of_birth).to eq(person_updated_event.date_of_birth)
      expect(dto_builder.email_address).to eq(person_updated_event.email_address)
      expect(dto_builder.date_of_death).to eq(person_updated_event.date_of_death)
      expect(dto_builder.file_number).to eq(person_updated_event.file_number)
      expect(dto_builder.is_veteran).to eq(person_updated_event.is_veteran)
    end
  end
end
