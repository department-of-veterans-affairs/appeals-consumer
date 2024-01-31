# frozen_string_literal: true

# This class is used to build out a Claim Review object from an instance of DecisionReviewCreated
class Builders::ClaimReviewBuilder
  attr_reader :claim_review

  def self.build(decision_review_created)
    builder = new
    builder.assign_attributes(decision_review_created)
    builder.claim_review
  end

  def initialize
    @claim_review = ClaimReview.new
  end

  def assign_attributes(decision_review_created)
    assign_filed_by_va_gov(decision_review_created)
    assign_receipt_date(decision_review_created)
    assign_legacy_opt_in_approved(decision_review_created)
    calculate_veteran_is_not_claimant(decision_review_created)
    assign_informal_conference(decision_review_created)
    assign_same_office(decision_review_created)
  end

  private
  
  # always nil
  def assign_filed_by_va_gov(decision_review_created); end

  def assign_receipt_date(decision_review_created); end

  def assign_legacy_opt_in_approved(decision_review_created); end

  def calculate_veteran_is_not_claimant(decision_review_created); end

  def assign_informal_conference(decision_review_created); end

  def assign_same_office(decision_review_created); end
end
