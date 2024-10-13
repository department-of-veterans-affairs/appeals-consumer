# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCreated::ClaimantBuilder
class DecisionReviewCreated::Claimant
  attr_accessor :payee_code, :type, :participant_id, :name_suffix, :ssn, :date_of_birth, :first_name, :middle_name,
                :last_name, :email
end
