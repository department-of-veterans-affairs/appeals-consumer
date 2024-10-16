# frozen_string_literal: true

# This class is used to build out a DecisionReviewCreated::Claimant object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::ClaimantBuilder < Builders::BaseClaimantBuilder
  def initialize(decision_review_model)
    @claimant = DecisionReviewCreated::Claimant.new
    super
  end
end
