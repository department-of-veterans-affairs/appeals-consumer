# frozen_string_literal: true

class VeteranSerializer
  attr_accessor :veteran

  def initialize(veteran)
    @veteran = veteran
  end

  def attributes
    {
      "participant_id" => veteran.participant_id,
      "bgs_last_synced_at" => veteran.bgs_last_synced_at,
      "closest_regional_office" => veteran.closest_regional_office,
      "date_of_death" => veteran.date_of_death,
      "date_of_death_reported_at" => veteran.date_of_death_reported_at,
      "name_suffix" => veteran.name_suffix
    }
  end
end
