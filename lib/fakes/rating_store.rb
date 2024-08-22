# frozen_string_literal: true

class Fakes::RatingStore < Fakes::PersistentStore
  class << self
    def redis_ns
      "ratings_#{Rails.env}"
    end
  end

  def all_veteran_participant_ids
    prefix = "#{self.class.redis_ns}:"
    all_keys.map { |key| key.sub(/^#{prefix}/, "") }
  end

  def store_rating_profile_record(participant_id, record)
    deflate_and_store(participant_id, record)
  end
end
