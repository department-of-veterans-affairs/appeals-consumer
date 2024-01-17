# frozen_string_literal: true

# This module is used to validate incoming attribute names and data types
# Any class wishing to use this module should have a method called #attribute_types
# Reference decision_review_created#attribute_types for more information
module MessagePayloadValidator
  # Validates attribute names and data types
  def validate(message_payload)
    validate_attribute_names(message_payload.keys)

    attribute_types.each do |name, type|
      validate_attribute_data_types(message_payload, name, type)
    end
  end

  # Checks that incoming attribute names match the message_payload listed in class#attribute_types
  # Fails out of workflow if there is an unknown attribute found
  def validate_attribute_names(attribute_names)
    unknown_attributes = attribute_names.reject { |attr| attribute_types.key?(attr) }

    fail ArgumentError, "Unknown attributes: #{unknown_attributes.join(', ')}" unless unknown_attributes.empty?
  end

  # Checks that incoming attribute types match the attribute types listed in class#attribute_types
  # Fails out of workflow if there is an unexpected data type found
  def validate_attribute_data_types(message_payload, name, type)
    value = message_payload[name]
    allowed_types = type.is_a?(Array) ? type : [type]

    unless allowed_types.any? { |type| value.is_a?(type) }
      fail ArgumentError, "#{name} must be one of the allowed types #{allowed_types}, got #{value.class}."
    end
  end
end
