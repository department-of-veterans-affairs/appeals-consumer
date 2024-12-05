# frozen_string_literal: true

# this payload is just a placeholder for now. We will have to update this with the specific payload.
# this payload outline came from the solutioning.
FactoryBot.define do
  factory :person_updated_event, class: "Events::PersonUpdatedEvent" do
    message_payload do
      {
        "date_of_birth" => Date.new(1980, 1, 1).to_time.to_s,
        "date_of_death" => Date.new(2022, 1, 1).to_time.to_s,
        "file_number" => "123456789",
        "first_name" => "Bill",
        "last_name" => "Tester",
        "middle_name" => "T",
        "participant_id" => 987654321,
        "social_security_number" => "834295567",
        "name_suffix" => nil,
        "veteran_indicator" => true
      }.to_json
    end
    partition { 1 }
    sequence(:offset) { Event.any? ? (Event.last.offset + 1) : 1 }
  end
end
