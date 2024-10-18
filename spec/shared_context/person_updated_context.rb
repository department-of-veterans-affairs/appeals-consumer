# frozen_string_literal: true

shared_context "person_updated_context" do
  let(:message_payload) do
    {
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
  end

  let(:message_payload_nil_pid) do
    {
      "date_of_birth" => Date.new(1980, 1, 1).to_time.to_s,
      "date_of_death" => Date.new(2022, 1, 1).to_time.to_s,
      "file_number" => "123456789",
      "first_name" => "Bill",
      "last_name" => "Tester",
      "middle_name" => "T",
      "participant_id" => nil,
      "prefix" => "Mr",
      "ssn" => "834295567",
      "name_suffix" => nil,
      "is_veteran" => true
    }
  end
end
