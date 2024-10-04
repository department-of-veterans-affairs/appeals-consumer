# frozen_string_literal: true

# This module is used to validate incoming message_payload presence, attribute names, and data types
# Any class wishing to use this module should have a method called #attribute_types
# as well as call #validate(message_payload, self.class.name) before assigning attributes

# Reference DecisionReviewCreated#attribute_types and DecisionReviewCreated#initialize for more information
module MessagePayloadValidator
  # Validates attribute names and data types
  def validate(message_payload, class_name)
    validate_presence(message_payload, class_name)
    log_unknown_attribute_names(message_payload.keys, class_name)
    validate_attribute_data_types(message_payload, class_name)
  end

  # Fails out of workflow if message_payload is nil or contains an empty object
  def validate_presence(message_payload, class_name)
    if message_payload.blank?
      fail ArgumentError, "#{class_name}: Message payload cannot be empty or nil"
    end
  end

  # Checks that incoming attribute names match the keys listed in class#attribute_types
  # If an unknown attribute is found, logs the names of all unknown attributes
  def log_unknown_attribute_names(attribute_names, class_name)
    unknown_attributes = attribute_names.reject { |attr| attribute_types.key?(attr) }

    unless unknown_attributes.empty?
      Rails.logger.info("#{class_name}: Unknown attributes - #{unknown_attributes.join(', ')}")
    end
  end

  # Checks that incoming data types match the attribute types listed in class#attribute_types
  # Fails out of workflow if there is an unexpected data type found
  def validate_attribute_data_types(message_payload, class_name)
    attribute_types.each do |name, type|
      value = message_payload[name]
      allowed_types = [type].flatten

      unless allowed_types.any? { |type| value.is_a?(type) }
        error_message = "#{class_name}: #{name} must be one of the allowed types - #{allowed_types}, got #{value.class}"
        fail ArgumentError, error_message
      end
    end
  end
end
