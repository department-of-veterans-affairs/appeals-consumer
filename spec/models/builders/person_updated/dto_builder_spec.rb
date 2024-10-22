# frozen_string_literal: true

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  message_payload = {
    "date_of_birth" => Date.new(1980, 1, 1).to_time.to_s,
    "date_of_death" => Date.new(2022, 1, 1).to_time.to_s,
    "file_number" => "123456789",
    "first_name" => "Bill",
    "last_name" => "Tester",
    "middle_name" => "T",
    "participant_id" => "987654321",
    "prefix" => "Mr",
    "ssn" => "834295567",
    "name_suffix" => nil,
    "is_veteran" => true
  }
  # let(:person_updated_event) do
  #   create(:person_updated_event, type: "Events::PersonUpdatedEvent")
  # end
  # let(:dto_builder) { described_class.new(person_updated_event) }
  # let(:event_id) { person_updated_event.id }

  describe "initialize" do
    context "when a person_updated object is found from a mocked payload (before actually building)" do
      let(:pu_event) { create(:person_updated_event, message_payload.to_json) }
      let(:pu) { build(:person_updated) }

      it "should return a PersonUpdatedDtoBuilder object with response and pii attributes(not in payload)" do 
        allow_any_instance_of(Builders::PersonUpdated::DtoBuilder).to receive(:build_person_updated)
          .with(JSON.parse(pu_event.message_payload)).and_return(pu)
      end

      it "calls MetricsService to record metrics" do
        expect(MetricsService).to receive(:record).with(
          "Build person updated #{pu_event}",
          service: :dto_builder,
          name: "Builders::PersonUpdated::DtoBuilder.initialize"
        ).and_call_original

        dto_builder
      end
    end

    xit "initializes instance variables" do
      expect(dto_builder.instance_variable_get(:@person_updated)).to be_a(Transformers::PersonUpdated)
    end
  end

  describe "#assign_attributes" do
    xit "correctly assigns attributes" do
      require 'pry';binding.pry
      expect(dto_builder.instance_variable_get(:@first_name)).to eq(person_updated_event.first_name)
      expect(dto_builder.instance_variable_get(:@last_name)).to eq(person_updated_event.last_name)
      expect(dto_builder.instance_variable_get(:@middle_name)).to eq(person_updated_event.middle_name)
      expect(dto_builder.instance_variable_get(:@name_suffix)).to eq(person_updated_event.name_suffix)
      expect(dto_builder.instance_variable_get(:@participant_id)).to eq(person_updated_event.participant_id)
      expect(dto_builder.instance_variable_get(:@ssn)).to eq(person_updated_event.ssn)
      expect(dto_builder.instance_variable_get(:@date_of_birth)).to eq(person_updated_event.date_of_birth)
      expect(dto_builder.instance_variable_gete(:@mail_address)).to eq(person_updated_event.email_address)
      expect(dto_builder.instance_variable_getd(:@ate_of_death)).to eq(person_updated_event.date_of_death)
      expect(dto_builder.instance_variable_get(:@file_number)).to eq(person_updated_event.file_number)
      expect(dto_builder.instance_variable_get(:@is_veteran)).to eq(person_updated_event.is_veteran)
    end
  end
end
