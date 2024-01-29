# frozen_string_literal: true

class VeteranSerializer
  include JSONAPI::Serializer

  attributes :participant_id, :bgs_last_synced_at, :closest_regional_office, :date_of_death, :date_of_death_reported_at,
             :name_suffix
end
