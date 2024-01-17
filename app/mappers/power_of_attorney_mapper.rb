# frozen_string_literal: true

module PowerOfAttorneyMapper
  
    # This is here so when we include this module
    # in classes (e.g. in PoaRepository),
    # the class itself and not just its instance
    # get the methods from this class.
    def self.included(base)
      base.extend(PowerOfAttorneyMapper)
    end
  
    def get_limited_poas_hash_from_bis(bis_response)
      return unless bis_response
  
      limited_poas_hash = {}
  
      Array.wrap(bis_response).map do |lpoa|
        limited_poas_hash[lpoa[:bnft_claim_id]] = {
          limited_poa_code: lpoa[:poa_cd],
          limited_poa_access: lpoa[:authzn_poa_access_ind]
        }
      end
  
      limited_poas_hash
    end
  end