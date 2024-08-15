# frozen_string_literal: true

describe DecisionReviewUpdated::ClaimReview do
  let(:decision_review_updated) { build(:decision_review_updated) }
  let(:claim_review) { Builders::DecisionReviewUpdated::ClaimReviewBuilder.build(decision_review_updated) }

  it "allows reader and writer access for attributes" do
    expect(claim_review.legacy_opt_in_approved).to eq(false)
    expect(claim_review.informal_conference).to eq(false)
    expect(claim_review.same_office).to eq(false)
  end
end
