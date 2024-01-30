# frozen_string_literal: true

FactoryBot.define do
  factory :end_product_establishment do
    claim_date { Date.new(2022, 1, 1) }
    code { "030HLRR" }
    modifier { "030" }
    reference_id { "147852369" }
  end
end
