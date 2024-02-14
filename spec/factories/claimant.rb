# frozen_string_literal: true

FactoryBot.define do
  factory :claimant do
    payee_code { "00" }
    type { "VeteranClaimant" }
    participant_id { "123456789" }
    name_suffix { nil }
    ssn { "987654321" }
    date_of_birth { Date.new(2022, 1, 1) }
    first_name { "John" }
    middle_name { "Russell" }
    last_name { "Smith" }
    email { "johnrsmith@gmail.com" }
  end
end
