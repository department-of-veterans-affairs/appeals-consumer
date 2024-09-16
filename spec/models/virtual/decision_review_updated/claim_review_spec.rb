# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe DecisionReviewUpdated::ClaimReview do
  include_context "decision_review_updated_context"

  let(:event_id) { 67_671 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:claim_review) { Builders::DecisionReviewUpdated::ClaimReviewBuilder.build(decision_review_updated_model) }

  it "allows reader and writer access for attributes" do
    expect(claim_review.legacy_opt_in_approved).to eq(false)
    expect(claim_review.informal_conference).to eq(false)
    expect(claim_review.same_office).to eq(false)
  end
end
