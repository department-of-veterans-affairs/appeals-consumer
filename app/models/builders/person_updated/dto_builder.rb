# frozen_string_literal: true

class Builders::PersonUpdated::DtoBuilder
  attr_reader :participant_id, :payload

  def initialize(person_updated_event)
    MetricsService.record("Build person updated #{person_updated_event}",
                          service: :dto_builder,
                          name: "Builders::PersonUpdated::DtoBuilder.initialize") do
      @event_id = person_updated_event.id
      @person_updated = build_person_updated(person_updated_event.message_payload_hash)
      assign_attributes
    end
  end

  def assign_attributes
    assign_participant_id
    assign_first_name
    assign_last_name
    calculate_middle_name
    calculate_name_suffix
    calculate_ssn
    calculate_date_of_birth
    calculate_email_address
    calculate_date_of_death
    assign_file_number
    assign_veteran_indicator
  end

  private

  def assign_first_name
    @person_updated.first_name = @person_updated_event.first_name
  end

  def assign_last_name
    @person_updated.last_name = @person_updated_event.last_name
  end

  def calculate_middle_name
    @person_updated.middle_name = @person_updated_event.middle_name
  end

  def calculate_name_suffix
    @person_updaed.name_suffix = @person_updated_event.name_suffix
  end

  def assign_participant_id
    @person_updated.participant_id = @person_updated_event.participant_id
  end

  def calculate_ssn
    @person_updated.ssn = @person_updated_event.ssn
  end

  def calculate_date_of_birth
    @person_udated.date_of_birth = @person_updated_event.date_of_birth if @person_updated_event.date_of_birth
  end

  def calculate_email_address
    @person_updated.email_address = @person_updated_event.email_address
  end

  def calculate_date_of_death
    @person_updated.date_of_death = @person_updated_event.date_of_death if @person_updated_event.date_of_death
  end

  def assign_file_number
    @person_updated.file_number = @person_updated_event.file_number
  end

  def assign_veteran_indicator
    @person_updated.is_veteran = @person_updated_event.is_veteran
  end

  def build_person_updated(message_payload)
    Transformers::PersonUpdated.new(@participant_id, message_payload)
  end
end
