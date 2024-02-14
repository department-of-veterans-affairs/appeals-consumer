# frozen_string_literal: true

# This class should be instantiated via Builders::VeteranBuilder
class Veteran
  attr_accessor :participant_id, :bgs_last_synced_at, :closest_regional_office, :date_of_death,
                :date_of_death_reported_at, :name_suffix, :ssn, :file_number, :first_name,
                :middle_name, :last_name
end
