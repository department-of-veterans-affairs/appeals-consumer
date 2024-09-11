# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReview::VeteranBuilder
class DecisionReview::Veteran
  attr_accessor :participant_id, :bgs_last_synced_at, :date_of_death, :name_suffix, :ssn, :file_number, :first_name,
                :middle_name, :last_name
end
