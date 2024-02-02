# frozen_string_literal: true

FactoryBot.define do
  factory :veteran do
    participant_id { "123456789" }
    bgs_last_synced_at { nil }
    closest_regional_office { nil }
    date_of_death { Date.new(2018, 1, 1) }
    date_of_death_reported_at { Date.new(2018, 2, 1) }
    name_suffix { nil }
    ssn { "963852741" }
    file_number { "963852741" }
    first_name { "John" }
    middle_name { "Russell" }
    last_name { "Smith" }
  end
end
