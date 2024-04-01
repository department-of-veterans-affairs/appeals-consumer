# frozen_string_literal: true

# This is the parent DTO Builder class. It holds common functionality used amungst
# various DTO Builders.
class Builders::BaseDtoBuilder
  # rubocop:disable Style/MutableConstant
  PII_FIELDS = %w[
    ssn
    filenumber
    file_number
    first_name
    middle_name
    last_name
    date_of_birth
    email
  ]
  # rubocop:enable Style/MutableConstant

  # :reek:UtilityFunction
  def clean_pii(hashable_model)
    hashable_model.as_json(except: Builders::BaseDtoBuilder::PII_FIELDS)
  end

  # :reek:FeatureEnvy
  def validate_no_pii(hash_response)
    hash_response.extend Hashie::Extensions::DeepFind
    Builders::BaseDtoBuilder::PII_FIELDS.each do |field|
      unless hash_response.deep_find_all(field).blank?
        fail AppealsConsumer::Error::PIIFoundViolationError, "PII field detected: #{field}"
      end
    end
    hash_response
  end
end
