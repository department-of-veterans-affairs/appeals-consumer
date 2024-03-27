# frozen_string_literal: true

FactoryBot.define do
  factory :end_product_establishment,
          class: "DecisionReviewCreated::EndProductEstablishment" do
    benefit_type_code { "0" }
    claim_date { Date.new(2022, 1, 1) }
    code { "030HLRR" }
    modifier { "030" }
    payee_code { "00" }
    limited_poa_access { nil }
    limited_poa_code { nil }
    committed_at { Time.now.utc }
    established_at { Time.now.utc }
    last_synced_at { Time.now.utc }
    synced_status { "RFD" }
    development_item_reference_id { nil }
    reference_id { "147852369" }
  end
end
