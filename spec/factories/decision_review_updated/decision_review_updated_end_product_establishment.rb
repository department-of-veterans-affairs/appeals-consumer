# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated_end_product_establishment,
          class: "DecisionReviewUpdated::EndProductEstablishment" do
    development_item_reference_id { "123456" }
    reference_id { "123456789" }
    last_synced_at { "2024-09-17T17:39:55.426Z" }
    synced_status { "PEND" }
  end
end
