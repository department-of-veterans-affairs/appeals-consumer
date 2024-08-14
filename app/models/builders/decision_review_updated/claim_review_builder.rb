# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewUpdated
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
    assign_informal_conference
    assign_same_office
    calculate_legacy_opt_in_approved
  end

  private

  def assign_informal_conference
    @claim_review.informal_conference = decision_review_updated.informal_conference_requested
  end

  def assign_same_office
    @claim_review.same_office = decision_review_updated.same_station_review_requested
  end

  def calculate_legacy_opt_in_approved
    @claim_review.legacy_opt_in_approved = any_opted_in_issues?
  end

  def any_opted_in_issues?
    combine_decision_review_issues.any? { |issue| !!issue.soc_opt_in }
  end

  # Combines decision review issues of all types into single array
  def combine_decision_review_issues
    all_decision_review_issues = []
    decision_review_issues.each { |issues| all_decision_review_issues += issues }
    all_decision_review_issues.flatten
  end

  def decision_review_issues
    [
      decision_review_updated.decision_review_issues_created,
      decision_review_updated.decision_review_issues_updated,
      decision_review_updated.decision_review_issues_removed,
      decision_review_updated.decision_review_issues_withdrawn
    ]
  end
end
