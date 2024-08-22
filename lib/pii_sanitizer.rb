# frozen_string_literal: true

module PiiSanitizer
  PII_FIELDS = %w[
    ssn
    filenumber
    file_number
    first_name
    middle_name
    last_name
    date_of_birth
    email
  ].freeze

  def self.sanitize(data)
    data = JSON.parse(data) if data.is_a?(String)

    deep_transform_keys_in_object(data) do |key, value|
      pii_fields.include?(key) ? "[REDACTED]" : value
    end
  end

  def self.deep_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.map do |key, value|
        scrubbed_value = if pii_fields.include?(key)
                           yield(key, value)
                         else
                           deep_transform_keys_in_object(value, &block)
                         end
        [key, scrubbed_value]
      end.to_h
    when Array
      object.map { |list_item| deep_transform_keys_in_object(list_item, &block) }
    else
      object
    end
  end

  def self.pii_fields
    PII_FIELDS + PII_FIELDS.map(&:to_sym)
  end
end
