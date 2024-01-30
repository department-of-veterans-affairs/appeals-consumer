# frozen_string_literal: true

# This serializer is used to remove attributes containing PII from the Caseflow-ingestible payload
class ClaimantSerializer
  attr_accessor :claimant

  def initialize(claimant)
    @claimant = claimant
  end

  def serialized_attributes
    {
      "payee_code" => claimant.payee_code,
      "type" => claimant.type,
      "participant_id" => claimant.participant_id,
      "name_suffix" => claimant.name_suffix
    }
  end
end
