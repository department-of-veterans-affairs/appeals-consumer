# frozen_string_literal: true

FactoryBot.define do
  factory :decision_review_updated_claim_review,
          class: "DecisionReviewUpdated::ClaimReview" do
    legacy_opt_in_approved { false }
    informal_conference { false }
    same_office { false }

    trait :legacy_opt_in_approved do
      legacy_opt_in_approved { true }
    end

    trait :informal_conference do
      informal_conference { true }
    end

    trait :same_office do
      same_office { true }
    end
  end
end
