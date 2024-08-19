# frozen_string_literal: true

# This class should be instantiated via Builders::DecisionReviewCreated::EndProductEstablishmentBuilder
class DecisionReviewCreated::EndProductEstablishment
  attr_accessor :benefit_type_code, :claim_date, :code, :modifier, :reference_id, :limited_poa_access,
                :limited_poa_code, :committed_at, :established_at, :last_synced_at, :synced_status,
                :development_item_reference_id, :payee_code
end
