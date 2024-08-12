# frozen_string_literal: true

class Builders::DecisionReviewUpdated::ClaimReviewBuilder
  attr_reader :claim_review, :decision_review_updated

  def self.build(decision_review_updated)
    builder = new(decision_review_updated)
    builder.assign_attributes
    builder.claim_review
  end

  def initialize(decision_review_updated)
    @decision_review_updated = decision_review_updated
    @claim_review = DecisionReviewUpdated::ClaimReview.new
  end

  def assign_attributes
    assign_auto_remand
    assign_remand_source_id
    assign_informal_conference
    assign_same_office
    assign_legacy_opt_in_approved
  end

  private

  def assign_auto_remand
    @claim_review.auto_remand = decision_review_updated.auto_remand
  end

  def assign_remand_source_id
    @claim_review.assign_remand_source_id = decision_review_updated.source_claim_id_for_remand
  end

  def assign_informal_conference
    @claim_review.informal_conference = decision_review_updated.informal_conference_requested
  end

  def assign_same_office
    @claim_review.same_office = decision_review_updated.same_station_review_requested
  end

  def assign_legacy_opt_in_approved
    @claim_review.legacy_opt_in_approved = decision_review_updated.soc_opt_in
  end
end
