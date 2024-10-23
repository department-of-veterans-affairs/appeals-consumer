# frozen_string_literal: true

# Transformers::PersonUpdated represents the message_payload from a PersonUpdatedEvent
# We are able to validate and assign instance vars using the Transformers::PersonUpdated class
class Transformers::PersonUpdated
  include MessagePayloadValidator

  attr_reader :event_id

  PERSON_UPDATED_ATTRIBUTES = {
    "participant_id" => String,
    "name_suffix" => [String, NilClass],
    "ssn" => [String, NilClass],
    "first_name" => [String, NilClass],
    "middle_name" => [String, NilClass],
    "last_name" => [String, NilClass],
    "email_address" => [String, NilClass],
    "date_of_birth" => [String, NilClass],
    "date_of_death" => [String, NilClass],
    "file_number" => [String, NilClass],
    "is_veteran" => [TrueClass, FalseClass]
  }.freeze

  # Allows read and write access for attributes
  PERSON_UPDATED_ATTRIBUTES.each_key { |attr_name| attr_accessor attr_name }

  # When PersonUpdated.new(message_payload) is called, this method will validate message_payload
  # presence, attribute names and data types, assign the incoming attributes to defined keys
  def initialize(event_id, message_payload)
    @event_id = event_id
    validate(message_payload, self.class.name)
    assign(message_payload)
  end

  # Lists the attributes and corresponding data types
  def attribute_types
    PERSON_UPDATED_ATTRIBUTES
  end

  # Assigns attributes from the message_payload to defined keys
  def assign(message_payload)
    PERSON_UPDATED_ATTRIBUTES.each_key do |attr|
      instance_variable_set("@#{attr}", message_payload[attr])
    end
  end
end
