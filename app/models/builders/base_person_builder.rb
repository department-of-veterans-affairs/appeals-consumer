# frozen_string_literal: true

class Builders::BasePersonBuilder
  attr_reader :person, :person_updated_model

  def self.build(person_updated_model)
    builder = new(person_updated_model)
    builder.assign_attributes
    builder.person
  end

  def initialize(person_updated_model)
    @person_updated_model = person_updated_model
    @person ||= BasePerson.new
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
    # assign_veteran_indicator <-- should this be an attribute?
  end

  private

  def assign_first_name
    @person.first_name = @person_updated_model.first_name
  end

  def assign_last_name
    @person.last_name = @person_updated_model.last_name
  end

  def calculate_middle_name
    @person.middle_name = @person_updated_model.middle_name
  end

  def calculate_name_suffix
    @person.name_suffix = @person_updated_model.name_suffix
  end

  def assign_participant_id
    @person.participant_id = @person_updated_model.participant_id
  end

  def calculate_ssn
    @person.ssn = @person_updated_model.ssn
  end

  def calculate_date_of_birth
    @person.date_of_birth = @person_updated_model.date_of_birth if @person_updated_model.date_of_birth
  end

  def calculate_email_address
    @person.email_address = @person_updated_model.email_address
  end

  # this date is sort of hard codded in the person factory
  def calculate_date_of_death
    @person.date_of_death = @person_updated_model.date_of_death if @person_updated_model.date_of_death 
  end

  def assign_file_number
    @person.file_number = @person_updated_model.file_number
  end

  # def assign_veteran_indicator; end
end
