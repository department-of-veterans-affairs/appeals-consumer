# frozen_string_literal: true

FactoryBot.define do
  factory :person,
          class: "PersonUpdated::Person" do
    participant_id { "123456789" }
    name_suffix { nil }
    ssn { "963852741" }
    first_name { "John" }
    middle_name { "Russell" }
    last_name { "Smith" }
    email_address { "email@email.com" }
    date_of_birth { Date.new(1969, 1, 1) }
    date_of_death { Date.new(2022, 1, 1) }
    file_number { "123456789" }
    is_veteran { false }

    # do we need date of birth?

    trait :veteran do
      is_veteran { true }
    end
  end
end
