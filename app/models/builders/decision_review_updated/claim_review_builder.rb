# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewUpdated
class Builders::DecisionReviewUpdated::ClaimReviewBuilder
  attr_reader :claim_review, :decision_review_model

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.assign_attributes
    builder.claim_review
  end

  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
    @claim_review = DecisionReviewUpdated::ClaimReview.new
  end

  def assign_attributes
    assign_informal_conference
    assign_same_office
    calculate_legacy_opt_in_approved
  end

  private

  def assign_informal_conference
    @claim_review.informal_conference = decision_review_model.informal_conference_requested
  end

  def assign_same_office
    @claim_review.same_office = decision_review_model.same_station_review_requested
  end

  def calculate_legacy_opt_in_approved
    @claim_review.legacy_opt_in_approved = any_opted_in_issues?
  end

  def any_opted_in_issues?
    all_decision_review_updated_issues.any? { |issue| !!issue.soc_opt_in }
  end

  def all_decision_review_updated_issues
    [
      decision_review_updated_issues_created,
      decision_review_updated_issues_updated,
      decision_review_updated_issues_removed,
      decision_review_updated_issues_withdrawn,
      decision_review_updated_issues_not_changed
    ].flatten
  end

  def decision_review_updated_issues_created
    decision_review_model.decision_review_issues_created
  end

  def decision_review_updated_issues_updated
    decision_review_model.decision_review_issues_updated
  end

  def decision_review_updated_issues_removed
    decision_review_model.decision_review_issues_removed
  end

  def decision_review_updated_issues_withdrawn
    decision_review_model.decision_review_issues_withdrawn
  end

  def decision_review_updated_issues_not_changed
    decision_review_model.decision_review_issues_not_changed
  end
end
