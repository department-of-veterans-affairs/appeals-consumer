class Builders::DtoBuilder

  class PIIFoundViolationError < StandardError; end

  PII_FIELDS = %w[
    ssn
    filenumber
    first_name
    middle_name
    last_name
    date_of_birth
    email
  ]

  # :reek:UtilityFunction
  def clean_pii(hashable_model)
    hashable_model.as_json(except: Builders::DtoBuilder::PII_FIELDS)
  end

  # :reek:FeatureEnvy
  def validate_no_pii(hash_response)
    hash_response.extend Hashie::Extensions::DeepFind
    Builders::DtoBuilder::PII_FIELDS.each do |field|
      unless hash_response.deep_find_all(field).blank?
        fail PIIFoundViolationError, "PII field detected: #{field}"
      end
    end
    hash_response
  end
end