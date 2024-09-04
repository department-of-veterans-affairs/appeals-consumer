# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated_end_product_establishment,
          class: "DecisionReviewUpdated::EndProductEstablishment" do
    development_item_reference_id { "123456" }
    reference_id { "123456789" }
  end
end
