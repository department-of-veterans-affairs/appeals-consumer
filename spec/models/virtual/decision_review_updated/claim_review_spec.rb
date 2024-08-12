# frozen_string_literal: true

describe DecisionReviewUpdated::ClaimReview do
  let(:claim_review) { build(:decision_review_updated_claim_review) }

  it "allows reader and writer access for attributes" do
    expect(claim_review.auto_remand).to eq("something")
    expect(claim_review.legacy_opt_in_approved).to eq(true)
    expect(claim_review.informal_conference).to eq(true)
    expect(claim_review.same_office).to eq(true)
  end
end
