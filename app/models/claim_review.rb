# frozen_string_literal: true

# This class should be instantiated via Builders::ClaimReviewBuilder
class ClaimReview
  attr_accessor :filed_by_va_gov, :receipt_date, :legacy_opt_in_approved, :veteran_is_not_claimant, :higher_level_review,
                :informal_conference, :same_office
end
