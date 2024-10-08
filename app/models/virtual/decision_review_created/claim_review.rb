# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCreated::ClaimReviewBuilder
class DecisionReviewCreated::ClaimReview
  attr_accessor :filed_by_va_gov, :receipt_date, :legacy_opt_in_approved, :veteran_is_not_claimant,
                :informal_conference, :same_office, :benefit_type, :establishment_attempted_at,
                :establishment_last_submitted_at, :establishment_processed_at, :establishment_submitted_at
end
