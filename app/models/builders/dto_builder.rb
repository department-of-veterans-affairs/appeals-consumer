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
end