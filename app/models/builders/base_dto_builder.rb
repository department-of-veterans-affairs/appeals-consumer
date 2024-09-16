# frozen_string_literal: true

# This is the parent DTO Builder class. It holds common functionality used amungst
# various DTO Builders.
class Builders::BaseDtoBuilder
  attr_reader :vet_file_number, :vet_ssn, :vet_first_name,
              :vet_middle_name, :vet_last_name, :claimant_ssn, :claimant_dob,
              :claimant_first_name, :claimant_middle_name, :claimant_last_name, :claimant_email

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
  def validate_no_pii(payload)
    payload.extend Hashie::Extensions::DeepFind
    Builders::BaseDtoBuilder::PII_FIELDS.each do |field|
      unless payload.deep_find_all(field).blank?
        fail AppealsConsumer::Error::PIIFoundViolationError, "PII field detected: #{field}"
      end
    end
    payload
  end

  # Allows all DTO Builders access to both Veteran and Claimant information
  def assign_from_retrievals
    @vet_ssn = assign_vet_ssn
    @vet_file_number = assign_vet_file_number
    @vet_first_name = assign_vet_first_name
    @vet_last_name = assign_vet_last_name
    @vet_middle_name = assign_vet_middle_name
    @claimant_ssn = assign_claimant_ssn
    @claimant_dob = assign_claimant_dob
    @claimant_first_name = assign_claimant_first_name
    @claimant_middle_name = assign_claimant_middle_name
    @claimant_last_name = assign_claimant_last_name
    @claimant_email = assign_claimant_email
  end

  def assign_vet_ssn
    @veteran.ssn
  end

  def assign_vet_file_number
    @veteran.file_number
  end

  def assign_vet_first_name
    @veteran.first_name
  end

  def assign_vet_last_name
    @veteran.last_name
  end

  def assign_vet_middle_name
    @veteran.middle_name
  end

  def assign_claimant_ssn
    @claimant.ssn
  end

  def assign_claimant_dob
    @claimant.date_of_birth
  end

  def assign_claimant_first_name
    @claimant.first_name
  end

  def assign_claimant_middle_name
    @claimant.middle_name
  end

  def assign_claimant_last_name
    @claimant.last_name
  end

  def assign_claimant_email
    @claimant.email
  end
end
