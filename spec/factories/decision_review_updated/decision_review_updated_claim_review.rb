# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated_claim_review,
          class: "DecisionReviewUpdated::ClaimReview" do
    auto_remand { "something" }
    legacy_opt_in_approved { true }
    informal_conference { true }
    same_office { true }
  end
end
