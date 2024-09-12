# frozen_string_literal: true

FactoryBot.define do
  factory :veteran,
          class: "DecisionReviewCreated::Veteran" do
    participant_id { "123456789" }
    bgs_last_synced_at { nil }
    date_of_death { Date.new(2018, 1, 1) }
    name_suffix { nil }
    ssn { "963852741" }
    file_number { "123456789" }
    first_name { "John" }
    middle_name { "Russell" }
    last_name { "Smith" }

    trait :without_bis_attrs do
      date_of_death { nil }
      name_suffix { nil }
      ssn { nil }
      middle_name { nil }
    end
  end
end
