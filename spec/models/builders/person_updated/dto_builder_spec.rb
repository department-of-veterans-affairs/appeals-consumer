# frozen_string_literal: true

RSpec.describe Builders::PersonUpdated::DtoBuilder, type: :model do
  let(:person_updated_event) do
    create(:person_updated_event, type: "Events::PersonUpdatedEvent")
  end

  let(:dto_builder) { described_class.new(person_updated_event) }

  let(:event_id) { person_updated_event.id }

  let(:person_record) do
    {
      "date_of_birth": Date.new(1980, 1, 1).to_time.to_s,
      "date_of_death": Date.new(2022, 1, 1).to_time.to_s,
      "file_number": "123456789",
      "first_name": "Bill",
      "last_name": "Tester",
      "middle_name": "T",
      "participant_id": "987654321",
      "prefix": "Mr",
      "ssn": "834295567",
      "name_suffix": nil,
      "is_veteran": true
    }
  end

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
      expect(dto_builder.instance_variable_get(:@person_updated)).to be_instance_of(Transformers::PersonUpdated)
      expect(dto_builder.instance_variable_get(:@participant_id)).to be_instance_of(String)
      expect(dto_builder.instance_variable_get(:@first_name)).to be_instance_of(String)
      expect(dto_builder.instance_variable_get(:@date_of_birth)).to be_instance_of(String)
      expect(dto_builder.instance_variable_get(:@is_veteran)).to be_instance_of(TrueClass)
    end
  end

  describe "#assign_attributes" do
    it "correctly assigns attribbutes" do
      expect(dto_builder.instance_variable_get(:@first_name)).to eq(person_record[:first_name])
      expect(dto_builder.instance_variable_get(:@last_name)).to eq(person_record[:last_name])
      expect(dto_builder.instance_variable_get(:@middle_name)).to eq(person_record[:middle_name])
      expect(dto_builder.instance_variable_get(:@name_suffix)).to eq(person_record[:name_suffix])
      expect(dto_builder.instance_variable_get(:@participant_id)).to eq(person_record[:participant_id])
      expect(dto_builder.instance_variable_get(:@ssn)).to eq(person_record[:ssn])
      expect(dto_builder.instance_variable_get(:@date_of_birth)).to eq(person_record[:date_of_birth])
      expect(dto_builder.instance_variable_get(:@email_address)).to eq(person_record[:email_address])
      expect(dto_builder.instance_variable_get(:@date_of_death)).to eq(person_record[:date_of_death])
      expect(dto_builder.instance_variable_get(:@file_number)).to eq(person_record[:file_number])
      expect(dto_builder.instance_variable_get(:@is_veteran)).to eq(person_record[:is_veteran])
    end
  end
end
