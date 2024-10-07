class Builders::BasePersonBuilder
  attr_reader :person, :bis_record

  def self.build(what_is_our_arg) # <-- do we pass in decision review model here as well?
    builder = new(what_is_our_arg) # <-- do we pass in decision review model here as well?
    builder.assign_attributes
    builder.person
  end

  def intialize(_what_is_our_arg) # <-- do we pass in decision review model here as well?
    @decision_review_model = decision_review_model
    @person ||= BasePerson.new
    @bis_record = fetch_person_bis_record # <-- is this a real thing?
  end

  def assign_attributes
    assign_participant_id
    calculate_first_name
    calculate_last_name
    calculate_middle_name
    calculate_name_suffix
    calculate_ssn
    calculate_date_of_birth
    assign_file_number
    calculate_date_of_death
    assign_veteran_indicator
    # the attributes from solutioning are
    # FIRST_NM
    # LAST_NM
    # MIDDLE_NM
    # SUFFIX_NM
    # PTCPNT_ID
    # SSN_NBR
    # BIRTHDY_DT
    # FILE_NBR
    # DEATH_DT
    # VET_IND

    # following the pattern from the base_claiment_builder
    # and the base_veteran_buidler.
    # Is a person associated with a decision_review?
  end

  private

  def calculate_first_name
    person.first_name = @bis_record&.dig(:first_name)
  end

  def calculate_last_name
    person.last_name = @bis_record&.dig(:last_name)
  end

  def calculate_middle_name
    person.middle_name = @bis_record&.dig(:middle_name)
  end

  def calculate_name_suffix
    person.name_suffix = @bis_record&.dig(:name_suffix)
  end

  def assign_participant_id
    # person.participant_id = decision_review_model.person_participant_id
  end

  def calculate_ssn
    person.ssn = @bis_record&.dig(:ssn)
  end

  def calculate_date_of_birth
    person.date_of_birth = @bis_record&.dig(:birth_date).to_i * 1000 if @bis_record&.dig(:birth_date)
  end

  def assign_file_number
    # person.file_number = decision_review_model.file_number
  end

  def calculate_date_of_death
    person.date_of_death = convert_date_of_death_to_logical_type_int
  end

  def convert_date_of_death_to_logical_type_int
    date = bis_record&.dig(:date_of_death)

    if date
      target_date = Date.strptime(date, "%m/%d/%Y")
      (target_date - EPOCH_DATE).to_i
    end
  end

  def assign_veteran_indicator; end
end
