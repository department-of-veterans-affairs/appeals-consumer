# frozen_string_literal: true

require "shared_context/person_updated_context"

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  subject(:dto_builder) { described_class.new(person_updated_event) }

  include_context "person_updated_context"

  let(:person_updated_event) do
    create(:person_updated_event, type: "Events::PersonUpdatedEvent", message_payload: message_payload)
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
      expect(dto_builder.instance_variable_get(:@person)).to be_a(BasePerson)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attributes" do
      dto_builder.send(:assign_attributes)

      expect(dto_builder.instance_variable_get(:@person_updated).first_name)
        .to eq(person_updated_event.message_payload["first_name"])
      expect(dto_builder.instance_variable_get(:@person_updated).last_name)
        .to eq(person_updated_event.message_payload["last_name"])
      expect(dto_builder.instance_variable_get(:@person_updated).middle_name)
        .to eq(person_updated_event.message_payload["middle_name"])
      expect(dto_builder.instance_variable_get(:@person_updated).name_suffix)
        .to eq(person_updated_event.message_payload["name_suffix"])
      expect(dto_builder.instance_variable_get(:@person_updated).participant_id)
        .to eq(person_updated_event.message_payload["participant_id"])
      expect(dto_builder.instance_variable_get(:@person_updated).ssn).to eq(person_updated_event.message_payload["ssn"])
      expect(dto_builder.instance_variable_get(:@person_updated).date_of_birth)
        .to eq(person_updated_event.message_payload["date_of_birth"])
      expect(dto_builder.instance_variable_get(:@person_updated).email_address)
        .to eq(person_updated_event.message_payload["email_address"])
      expect(dto_builder.instance_variable_get(:@person_updated).date_of_death)
        .to eq(person_updated_event.message_payload["date_of_death"])
      expect(dto_builder.instance_variable_get(:@person_updated).file_number)
        .to eq(person_updated_event.message_payload["file_number"])
      expect(dto_builder.instance_variable_get(:@person_updated).is_veteran)
        .to eq(person_updated_event.message_payload["is_veteran"])
    end
  end

  describe "#private methods" do
    it "can assign first name" do
      expect(dto_builder.instance_variable_get(:@person).first_name)
        .to eq(dto_builder.instance_variable_get(:@person_updated).first_name)
    end

    it "can assign last name" do
      expect(dto_builder.instance_variable_get(:@person).last_name)
        .to eq(dto_builder.instance_variable_get(:@person_updated).last_name)
    end

    it "can assign middle name" do
      expect(dto_builder.instance_variable_get(:@person).middle_name)
        .to eq(dto_builder.instance_variable_get(:@person_updated).middle_name)
    end

    it "can assign name suffix" do
      expect(dto_builder.instance_variable_get(:@person).name_suffix)
        .to eq(dto_builder.instance_variable_get(:@person_updated).name_suffix)
    end

    it "can assign participant id" do
      expect(dto_builder.instance_variable_get(:@person).participant_id)
        .to eq(dto_builder.instance_variable_get(:@person_updated).participant_id)
    end

    it "can assign ssn" do
      expect(dto_builder.instance_variable_get(:@person).ssn)
        .to eq(dto_builder.instance_variable_get(:@person_updated).ssn)
    end

    it "can assign date of birth" do
      expect(dto_builder.instance_variable_get(:@person).date_of_birth)
        .to eq(dto_builder.instance_variable_get(:@person_updated).date_of_birth)
    end

    it "can assign email address" do
      expect(dto_builder.instance_variable_get(:@person).email_address)
        .to eq(dto_builder.instance_variable_get(:@person_updated).email_address)
    end

    it "can assign date of death" do
      expect(dto_builder.instance_variable_get(:@person).date_of_death)
        .to eq(dto_builder.instance_variable_get(:@person_updated).date_of_death)
    end

    it "can assign file number" do
      expect(dto_builder.instance_variable_get(:@person).file_number)
        .to eq(dto_builder.instance_variable_get(:@person_updated).file_number)
    end

    it "can assign veteran indicator" do
      expect(dto_builder.instance_variable_get(:@person).is_veteran)
        .to eq(dto_builder.instance_variable_get(:@person_updated).is_veteran)
    end
  end
end
