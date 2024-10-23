# frozen_string_literal: true

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  let(:person_updated_event) do
    create(:person_updated_event, type: "Events::PersonUpdatedEvent")
  end

  let(:dto_builder) { described_class.new(person_updated_event) }

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
      expect(dto_builder.instance_variable_get(:@person_updated)).to be_a(Transformers::PersonUpdated)
    end
  end

  describe "#_assign_payload" do
    it "should recieve the following methods: " do
      expect(dto_builder).to receive(:build_payload)
      dto_builder.send(:assign_payload)
    end
    it "should assing to @payload" do
      dto_builder.send(:assign_payload)
      expect(dto_builder.instance_variable_get(:@payload)).to be_instance_of(Hash)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attribbutes" do
      binding.pry
      expect(dto_builder.instance_variable_get(:@first_name)).to eq(person_updated_event.first_name)
      expect(dto_builder.instance_variable_get(:last_name)).to eq(person_updated_event.last_name)
      expect(dto_builder.instance_variable_get(:middle_name)).to eq(person_updated_event.middle_name)
      expect(dto_builder.instance_variable_get(:name_suffix)).to eq(person_updated_event.name_suffix)
      expect(dto_builder.instance_variable_get(:participant_id)).to eq(person_updated_event.participant_id)
      expect(dto_builder.instance_variable_get(:ssn)).to eq(person_updated_event.ssn)
      expect(dto_builder.instance_variable_get(:date_of_birth)).to eq(person_updated_event.date_of_birth)
      expect(dto_builder.instance_variable_get(:email_address)).to eq(person_updated_event.email_address)
      expect(dto_builder.instance_variable_get(:date_of_death)).to eq(person_updated_event.date_of_death)
      expect(dto_builder.instance_variable_get(:file_number)).to eq(person_updated_event.file_number)
      expect(dto_builder.instance_variable_get(:is_veteran)).to eq(person_updated_event.is_veteran)
    end
  end
end
