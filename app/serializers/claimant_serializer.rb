# frozen_string_literal: true

class ClaimantSerializer
  include JSONAPI::Serializer

  attributes :payee_code, :type, :participant_id, :name_suffix
end
