# frozen_string_literal: true

# This class is responsible for constructing a PersonUpdated payload that will be sent to Caseflow
class Builders::PersonUpdated::DtoBuilder
  attr_reader :payload

  def initialize(person_updated_event)
    MetricsService.record("Build person updated #{person_updated_event}",
                          service: :dto_builder,
                          name: "Builders::PersonUpdated::DtoBuilder.initialize") do
      @event_id = person_updated_event.id
      @participant_id = person_updated_event.participant_id.to_s
      @event_payload = person_updated_event.message_payload_hash
      @person_updated = build_person_updated
      assign_attributes
    end
  end

  def build_person_updated
    Transformers::PersonUpdated.new(@event_id, @event_payload)
  end

  def assign_attributes
    begin
      assign_first_name
      assign_last_name
      assign_middle_name
      assign_name_suffix
      assign_ssn
      assign_date_of_birth
      assign_date_of_death
      assign_file_number
      assign_veteran_indicator
      assign_payload
    rescue StandardError => error
      raise AppealsConsumer::Error::DtoBuildError,
            "Failed building from Builders::PersonUpdated::DtoBuilder: #{error.message}"
    end
  end

  private

  def assign_payload
    @payload = build_payload
  end

  def assign_first_name
    @first_name = @person_updated.first_name
  end

  def assign_last_name
    @last_name = @person_updated.last_name
  end

  def assign_middle_name
    @middle_name = @person_updated.middle_name
  end

  def assign_name_suffix
    @name_suffix = @person_updated.name_suffix
  end

  def assign_ssn
    @ssn = @person_updated.social_security_number
  end

  def assign_date_of_birth
    @date_of_birth = @person_updated.date_of_birth if @person_updated.date_of_birth
  end

  def assign_date_of_death
    @date_of_death = @person_updated.date_of_death if @person_updated.date_of_death
  end

  def assign_file_number
    @file_number = @person_updated.file_number
  end

  def assign_veteran_indicator
    @is_veteran = @person_updated.veteran_indicator
  end

  def build_payload
    {
      "event_id": @event_id,
      "participant_id": @participant_id,
      "first_name": @first_name,
      "middle_name": @middle_name,
      "last_name": @last_name,
      "name_suffix": @name_suffix,
      "ssn": @ssn,
      "date_of_birth": @date_of_birth,
      "date_of_death": @date_of_death,
      "file_number": @file_number,
      "is_veteran": @is_veteran
    }.as_json
  end
end
