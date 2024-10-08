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
    date_of_birth { Date.new(2022, 1, 1) }

    # do we need date of birth?

    # Will I need the trait?
    # trait :without_bis_attrs do
    #   # date_of_death { nil }
    #   name_suffix { nil }
    #   ssn { nil }
    #   middle_name { nil }
    # end
  end
end
