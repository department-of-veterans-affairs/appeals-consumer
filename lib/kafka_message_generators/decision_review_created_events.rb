# frozen_string_literal: true

module KafkaMessageGenerators
  # rubocop:disable Metrics/ClassLength
  class DecisionReviewCreatedEvents
    # all possible ep codes appeals-consumer could receive from vbms intake
    EP_CODES ||=
      {
        higher_level_review: {
          compensation: {
            rating: %w[030HLRR 930AMAHRC 930AMAHDER 930AMAHCRLQE 930AMAHDERCL 930AMAHCRNQE 930AMAHDERCN],
            nonrating: %w[030HLRNR 930AMAHNRC 930AMAHDENR 930AHCNRLQE 930AMAHDENCL 930AHCNRNQE 930AMAHDENCN]
          },
          pension: {
            rating: %w[030HLRRPMC 930AMAHRCPMC 930AHDERPMC 930AHCRLQPMC 930AHDERLPMC 930AHCRNQPMC 930AHDERNPMC],
            nonrating: %w[030HLRNRPMC 930AHNRCPMC 930AHDENRPMC 930AHCNRLPMC 930AHDENLPMC 930AHCNRNPMC 930AHDENNPMC]
          }
        },
        supplemental_claim: {
          compensation: {
            rating: %w[040SCR 040HDER 040AMDAOR 930AMASRC 930AMARRC 930AMADOR 930AMASCRLQE
                       930AMARRCLQE 930AMASCRNQE 930AMARRCNQE 040SCRGTY],
            nonrating: %w[040SCNR 040HDENR 040AMADONR 930AMASNRC 930AMARNRC 930AMADONR
                          930ASCNRLQE 930ARNRCLQE 930ASCNRNQE 930ARNRCNQE]
          },
          pension: {
            rating: %w[040SCRPMC 040HDERPMC 040ADORPMC 930AMASRCPMC 930AMARRCPMC 930ASCRLQPMC
                       930ARRCLQPMC 930ASCRNQPMC 930ARRCNQPMC 930ADORPMC],
            nonrating: %w[040SCNRPMC 040HDENRPMC 040ADONRPMC 930ASNRCPMC 930ARNRCPMC 930ASCNRLPMC
                          930ARNRCLPMC 930ASCNRNPMC 930ARNRCNPMC 930ADONRPMC]
          }
        }
      }.freeze

    # "DIC" is also a nonrating issue decision type but it isn't included in this last due
    # to it already being accounted for in the decision_review_created factory used throughout this class
    NONRATING_DECISION_TYPES ||=
      [
        "Accrued",
        "Allotment",
        "Allotment - Apportionment",
        "Attorney Fee",
        "Basic Eligibility",
        "Burial - Plot Allowance",
        "Burial - Transportation Allowance",
        "Burial - Service Connected",
        "Burial - Non Service Connected",
        "Burial - SC Burial and Transportation",
        "Burial - NSC Burial and Plot Allowance",
        "Burial - NSC Burial, Plot and Transportation",
        "Burial - Other",
        "Burial - No Burial Benefit Entitlement Due to Service",
        "Burial - State Plot Allowance",
        "Burial - Marker/Engraver Reimbursement",
        "Chapter 18",
        "Clothing Allowance",
        "Custody of Children",
        "DIC Spouse Status",
        "Dependency",
        "Disability Pay Adjustment",
        "Drill Pay Adjustment",
        "Election",
        "Expense",
        "Fraud",
        "Income",
        "Institutionalization Adjustment",
        "Medal of Honor",
        "Military Eligibility",
        "Net Worth",
        "Other Witholding Adjustment",
        "Retired Pay Adjustment",
        "Separation Pay Adjustment"
      ].freeze

    # clears the cache incase any records are currently stored
    # initializes variable that will hold file numbers to be removed from the cache
    # to test AppealsConsumer::Error::BisVeteranNotFound error
    def initialize
      clear_cache
      @file_numbers_to_remove_from_cache = []
    end

    # creates all vbms intake scenarios for every ep code
    # including scenarios that would raise an error within appeals-consumer
    def publish_messages!
      puts "Started creating messages..."
      messages = create_messages
      puts "Finished creating messages!"

      puts "Started preparing and publishing #{messages.flatten.count} messages..."
      messages.flatten.each do |message|
        formatted_message = convert_and_format_message(message)
        encoded_message = encode_message(formatted_message)
        publish_message(encoded_message)
      end
      puts "Finished publishing #{@published_messages_count} messages!"
    end

    private

    # incase any records are stored locally, clear the cache to prevent conflict
    def clear_cache
      BISService.clean!
    end

    def sc_issue?(ep_code)
      sc_ep_codes.include?(ep_code)
    end

    # create messages based on rating/nonrating
    def create_messages
      rating = create_rating_messages
      nonrating = create_nonrating_messages

      rating + nonrating
    end

    # create the same rating scenarios for both hlr/supplemental and compesation/pension
    def create_rating_messages
      [create_rating_ep_code_messages(rating_ep_codes)]
    end

    # create the same nonrating scenarios for both hlr/supplemental and compesation/pension
    def create_nonrating_messages
      [create_nonrating_ep_code_messages(nonrating_ep_codes)]
    end

    # creates all scenarios for HLR rating ep codes, including when the issue is unidentified
    def create_rating_ep_code_messages(ep_codes)
      ep_codes.map do |code|
        create_rating_issue_type_messages(code)
      end
    end

    # create messages for all types of rating issues
    # since only two fields are different on hlr vs supplemental messages (decision_review_type and eligibility_result),
    # create hlr messages for all rating ep codes then change the necessary fields for supplementals
    def create_rating_issue_type_messages(code)
      [
        create_hlr_rating_issue_messages(code),
        create_hlr_rating_decision_messages(code),
        create_hlr_decision_issue_prior_rating_messages(code),
        create_hlr_unidentified_rating_messages(code)
      ]
    end

    # creates scenarios for messages that have a prior_rating_decision_id
    def create_hlr_rating_issue_messages(code)
      rating_messages("rating_hlr", code)
    end

    # creates scenarios for messages that have a prior_decision_rating_disability_sequence_number
    def create_hlr_rating_decision_messages(code)
      rating_messages("rating_decision_hlr", code)
    end

    # creates scenarios for messages that have a prior_rating_decision_id and associated_caseflow_decision_id
    def create_hlr_decision_issue_prior_rating_messages(code)
      rating_messages("decision_issue_prior_rating_hlr", code)
    end

    # creates scenarios for messages that are unidentified and have a rating ep code
    def create_hlr_unidentified_rating_messages(code)
      rating_messages("rating_hlr_unidentified", code)
    end

    # only create valid eligible and invalid messages for unidentified issues
    # unidentified issues can't be declared ineligible until they are identified
    def rating_messages(issue_type, code)
      rating_eligible_messages = create_rating_eligible_messages(issue_type, code)
      rating_invalid_messages = create_rating_invalid_messages(issue_type, code)
      return rating_eligible_messages + rating_invalid_messages if unidentified?(issue_type)

      rating_ineligible_messages = create_ineligible_messages(issue_type, code)

      rating_eligible_messages + rating_invalid_messages + rating_ineligible_messages
    end

    def create_rating_eligible_messages(issue_type, code)
      rating_eligible_messages = create_valid_and_eligible_rating_messages(issue_type, code)

      [rating_eligible_messages]
    end

    def create_rating_invalid_messages(issue_type, code)
      rating_invalid_messages = create_invalid_messages(issue_type, code)

      [rating_invalid_messages]
    end

    # create different message scenarios depending on if the issue is unidentified, a rating decision, or
    # rating issue with or without an associated caseflow decision issue
    def create_valid_and_eligible_rating_messages(issue_type, code)
      rating_unidentified_messages = create_unidentified_messages(issue_type, code)
      return rating_unidentified_messages if unidentified?(issue_type)

      rating_decision_messages =
        create_identified_messages(issue_type, code, rating_unidentified_messages)
      return rating_decision_messages if rating_decision?(issue_type)

      assoc_decision_issue_messages = create_rating_issue_messages(issue_type, code, rating_decision_messages)
      return assoc_decision_issue_messages if associated_decision_issue?(issue_type)

      eligible_with_two_issues = create_eligible_with_two_issues(issue_type, code)
      contested_with_additional_issue = create_contested_with_additional_issue(issue_type, code)

      assoc_decision_issue_messages + eligible_with_two_issues + contested_with_additional_issue
    end

    # scenarios that exist for every issue type regardless of ep code
    def create_unidentified_messages(issue_type, code)
      veteran_claimant = create_drc_message("eligible_#{issue_type}_veteran_claimant", code)
      non_veteran_claimant = create_drc_message("eligible_#{issue_type}_non_veteran_claimant", code)
      no_decision_date = create_drc_message("eligible_#{issue_type}_without_prior_decision_notification_date", code)
      with_poa_access = create_drc_message_with_poa_access("eligible_#{issue_type}", code)
      without_poa_access = create_drc_message_without_poa_access("eligible_#{issue_type}", code)
      nil_poa_access = create_drc_message_with_nil_poa_access("eligible_#{issue_type}", code)

      [
        veteran_claimant,
        non_veteran_claimant,
        no_decision_date,
        with_poa_access,
        without_poa_access,
        nil_poa_access
      ]
    end

    # odd claim ids will have these poa values for the end product establishment record:
    # limited_poa_code: "OU3", limited_poa_access: "Y"
    def create_drc_message_with_poa_access(issue_trait, code)
      @with_poa_access_claim_id ||= 1
      drc = create_drc_message(issue_trait, code)
      set_claim_id(drc, @with_poa_access_claim_id)
      @with_poa_access_claim_id += 2

      drc
    end

    # even claim ids will have these poa values for the end product establishment record:
    # limited_poa_code: "007", limited_poa_access: "N"
    def create_drc_message_without_poa_access(issue_trait, code)
      @without_poa_access_claim_id ||= 2
      drc = create_drc_message(issue_trait, code)
      set_claim_id(drc, @without_poa_access_claim_id)
      @without_poa_access_claim_id += 2

      drc
    end

    # claim id value of 0 will return nil for the limited poa BIS call
    def create_drc_message_with_nil_poa_access(issue_trait, code)
      @nil_poa_access_claim_id ||= 0
      drc = create_drc_message(issue_trait, code)
      set_claim_id(drc, @nil_poa_access_claim_id)

      drc
    end

    def set_claim_id(drc, claim_id_int)
      drc.claim_id = claim_id_int
    end

    # scenarios that are applicable to rating decision messages
    def create_identified_messages(issue_type, code, valid_unidentified_messages)
      eligible_legacy = create_drc_message("eligible_#{issue_type}_legacy", code)
      time_override = create_drc_message("eligible_#{issue_type}_time_override", code)

      [eligible_legacy, time_override] + valid_unidentified_messages
    end

    # scenarios that are applicable to rating issues with or without an associated caseflow decision id
    def create_rating_issue_messages(issue_type, code, rating_decision_messages)
      with_ramp_id = create_drc_message("eligible_#{issue_type}_with_ramp_id", code)

      rating_decision_messages << with_ramp_id
    end

    # unidentified issues have different invalid scenarios than identified messages
    def create_invalid_messages(issue_type, code)
      invalid_unidentified_messages = create_invalid_unidentified_messages(issue_type, code)
      return invalid_unidentified_messages if unidentified?(issue_type)

      invalid_identified_messages = create_invalid_identified_messages(issue_type, code, invalid_unidentified_messages)
      return invalid_identified_messages if rating_decision?(issue_type) || associated_decision_issue?(issue_type)

      contested_issue = create_contested_issue(issue_type, code)

      invalid_identified_messages + contested_issue
    end

    def create_contested_issue(issue_type, code)
      drc = create_drc_message("ineligible_#{issue_type}_contested", code)

      [drc]
    end

    # scenarios that pertain to unidentified issues
    def create_invalid_unidentified_messages(issue_type, code)
      eligible_without_contention_id = create_drc_message("eligible_#{issue_type}_without_contention_id", code)
      bis_veteran_not_found = create_drc_message_and_track_file_number("eligible_#{issue_type}", code)
      bis_person_not_found =
        create_drc_message_without_bis_person("eligible_#{issue_type}", code)

      [
        eligible_without_contention_id,
        bis_veteran_not_found,
        bis_person_not_found
      ]
    end

    # message scenarios that pertain to identified rating decisions and rating issues
    # with or without an associated caseflow decision id
    def create_invalid_identified_messages(issue_type, code, invalid_unidentified_messages)
      pending_hlr_without_ri_id = create_drc_message("ineligible_#{issue_type}_pending_hlr_without_ri_id", code)
      ineligible_with_contention_id = create_drc_message("ineligible_#{issue_type}_with_contention_id", code)

      [pending_hlr_without_ri_id, ineligible_with_contention_id] + invalid_unidentified_messages
    end

    # ineligible scenarios only pertain to identified messages
    # "COMPLETED_BOARD" and "COMPLETED_HLR" do not pertain to supplementals
    def create_ineligible_messages(issue_type, code)
      ineligible_supp_messages = create_ineligible_supp_messages(issue_type, code)
      return ineligible_supp_messages if sc_issue?(code)

      create_ineligible_hlr_messages(issue_type, code, ineligible_supp_messages)
    end

    def create_ineligible_supp_messages(issue_type, code)
      untimely = create_drc_message("ineligible_#{issue_type}_time_restriction_untimely", code)
      before_ama = create_drc_message("ineligible_#{issue_type}_time_restriction_before_ama", code)
      no_soc_ssoc = create_drc_message("ineligible_#{issue_type}_no_soc_ssoc", code)
      pending_legacy_appeal =
        create_drc_message("ineligible_#{issue_type}_pending_legacy_appeal", code)
      legacy_time_restriction =
        create_drc_message("ineligible_#{issue_type}_legacy_time_restriction", code)
      pending_hlr = create_drc_message("ineligible_#{issue_type}_pending_hlr", code)
      pending_board = create_drc_message("ineligible_#{issue_type}_pending_board", code)
      pending_supplemental = create_drc_message("ineligible_#{issue_type}_pending_supplemental", code)

      [
        untimely,
        before_ama,
        no_soc_ssoc,
        pending_legacy_appeal,
        legacy_time_restriction,
        pending_hlr,
        pending_supplemental,
        pending_board
      ]
    end

    def create_ineligible_hlr_messages(issue_type, code, ineligible_supp_messages)
      completed_hlr = create_drc_message("ineligible_#{issue_type}_completed_hlr", code)
      completed_board = create_drc_message("ineligible_#{issue_type}_completed_board", code)

      [completed_hlr, completed_board] + ineligible_supp_messages
    end

    # create the message, randomize the file number, and add it to array that will test
    # AppealsConsumer::Error::BisVeteranNotFound error
    def create_drc_message_and_track_file_number(issue_trait, code)
      drc = create_drc_message(issue_trait, code)

      randomize_and_track_file_number(drc)
    end

    # randomize the file number value and add it to array that will remove it from the redis cache
    # this will test AppealsConsumer::Error::BisVeteranNotFound error
    def randomize_and_track_file_number(drc)
      drc.file_number = randomize_value("file_number", drc).to_s
      @file_numbers_to_remove_from_cache << drc.file_number
      drc
    end

    # if a claimant_participant_id is "", the fake BIS call with return an empty obj
    def create_drc_message_without_bis_person(issue_trait, code)
      drc = create_drc_message(issue_trait, code)
      drc.claimant_participant_id = ""
      drc
    end

    # represents a message post-consumption and post-deserialization
    # some fields must be changed to accurately reflect a message prior to consumption
    def create_drc_message(trait, ep_code)
      drc = FactoryBot.build(:decision_review_created, trait.to_sym, ep_code: ep_code)
      randomize_claim_id(drc)
      store_veteran_in_cache(drc)
      drc
    end

    # creates all scenarios for HLR rating ep codes, including when the issue is unidentified
    def create_nonrating_ep_code_messages(ep_codes)
      ep_codes.map do |code|
        create_nonrating_issue_type_messages(code)
      end
    end

    # create messages for all types of rating issues
    def create_nonrating_issue_type_messages(code)
      [
        create_nonrating_issue_messages(code),
        create_decision_issue_prior_nonrating_messages(code),
        create_unidentified_nonrating_messages(code)
      ]
    end

    # creates scenarios for messages that have a prior_non_rating_decision_id
    def create_nonrating_issue_messages(code)
      nonrating_messages("nonrating_hlr", code)
    end

    # creates scenarios for messages that have a prior_nonrating_decision_id and associated_caseflow_decision_id
    def create_decision_issue_prior_nonrating_messages(code)
      nonrating_messages("decision_issue_prior_nonrating_hlr", code)
    end

    # creates scenarios for messages that are unidentified and have a nonrating ep code
    def create_unidentified_nonrating_messages(code)
      nonrating_messages("nonrating_hlr_unidentified", code)
    end

    # only create valid eligible and invalid messages for unidentified issues
    # unidentified issues can't be declared ineligible until they are identified
    def nonrating_messages(issue_type, code)
      nonrating_eligible_messages = create_nonrating_eligible_messages(issue_type, code)
      nonrating_invalid_messages = create_nonrating_invalid_messages(issue_type, code)
      return nonrating_eligible_messages + nonrating_invalid_messages if unidentified?(issue_type)

      nonrating_ineligible_messages = create_ineligible_messages(issue_type, code)

      nonrating_eligible_messages + nonrating_invalid_messages + nonrating_ineligible_messages
    end

    def create_nonrating_eligible_messages(issue_type, code)
      nonrating_eligible_messages = create_valid_and_eligible_nonrating_messages(issue_type, code)

      [nonrating_eligible_messages]
    end

    def create_nonrating_invalid_messages(issue_type, code)
      nonrating_invalid_messages = create_invalid_messages(issue_type, code)

      [nonrating_invalid_messages]
    end

    # create different message scenarios depending on if the issue is unidentified or
    # a nonrating issue with or without an associated caseflow decision issue
    def create_valid_and_eligible_nonrating_messages(issue_type, code)
      nonrating_unidentified_messages = create_unidentified_messages(issue_type, code)
      return nonrating_unidentified_messages if unidentified?(issue_type)

      identified_messages = create_identified_messages(issue_type, code, nonrating_unidentified_messages)
      decision_type_messages = create_decision_type_messages(issue_type, code)
      return identified_messages + decision_type_messages if associated_decision_issue?(issue_type)

      eligible_with_two_issues = create_eligible_with_two_issues(issue_type, code)
      contested_with_additional_issue = create_contested_with_additional_issue(issue_type, code)

      identified_messages + decision_type_messages + eligible_with_two_issues + contested_with_additional_issue
    end

    def create_eligible_with_two_issues(issue_type, code)
      drc = create_drc_message("eligible_#{issue_type}_with_two_issues", code)

      [drc]
    end

    def create_contested_with_additional_issue(issue_type, code)
      drc = create_drc_message("ineligible_#{issue_type}_contested_with_additional_issue", code)

      [drc]
    end

    def create_decision_type_messages(issue_type, code)
      NONRATING_DECISION_TYPES.map do |decision_type|
        drc = create_drc_message("eligible_#{issue_type}", code)
        change_issue_decision_type_and_decision_text(drc, decision_type)
        drc
      end
    end

    def change_issue_decision_type_and_decision_text(drc, decision_type)
      drc.decision_review_issues.each do |issue|
        issue.prior_decision_type = decision_type
        issue.prior_decision_text = "#{decision_type}: Service connection for tetnus denied"
      end

      drc
    end

    # set claim_id to a random value
    def randomize_claim_id(drc)
      drc.claim_id = randomize_value("claim_id", drc)
    end

    # store veteran record in Fakes::VeteranStore for all messages
    # aside from the messages that specifically test AppealsConsumer::Error::BisVeteranNotFound error
    # rubocop:disable Metrics/MethodLength
    def store_veteran_in_cache(drc)
      veteran_bis_record =
        {
          file_number: drc.file_number,
          ptcpnt_id: drc.veteran_participant_id,
          sex: "M",
          first_name: drc.veteran_first_name,
          middle_name: "Russell",
          last_name: drc.veteran_last_name,
          name_suffix: "II",
          ssn: "987654321",
          address_line1: "122 Mullberry St.",
          address_line2: "PO BOX 123",
          address_line3: "Daisies",
          city: "Orlando",
          state: "FL",
          country: "USA",
          date_of_birth: "12/21/1989",
          date_of_death: "12/31/2019",
          zip_code: "94117",
          military_post_office_type_code: nil,
          military_postal_type_code: nil,
          service: [{ branch_of_service: "army", pay_grade: "E4" }]
        }

      Fakes::VeteranStore.new.store_veteran_record(drc.file_number, veteran_bis_record)
    end
    # rubocop:enable Metrics/MethodLength

    def hlr_compensation_rating_ep_codes
      EP_CODES[:higher_level_review][:compensation][:rating]
    end

    def hlr_compensation_nonrating_ep_codes
      EP_CODES[:higher_level_review][:compensation][:nonrating]
    end

    def hlr_pension_rating_ep_codes
      EP_CODES[:higher_level_review][:pension][:rating]
    end

    def hlr_pension_nonrating_ep_codes
      EP_CODES[:higher_level_review][:pension][:nonrating]
    end

    def sc_compensation_rating_ep_codes
      EP_CODES[:supplemental_claim][:compensation][:rating]
    end

    def sc_compensation_nonrating_ep_codes
      EP_CODES[:supplemental_claim][:compensation][:nonrating]
    end

    def sc_pension_rating_ep_codes
      EP_CODES[:supplemental_claim][:pension][:rating]
    end

    def sc_pension_nonrating_ep_codes
      EP_CODES[:supplemental_claim][:pension][:nonrating]
    end

    def sc_rating_ep_codes
      sc_compensation_rating_ep_codes + sc_pension_rating_ep_codes
    end

    def hlr_rating_ep_codes
      hlr_compensation_rating_ep_codes + hlr_pension_rating_ep_codes
    end

    def rating_ep_codes
      sc_rating_ep_codes + hlr_rating_ep_codes
    end

    def sc_nonrating_ep_codes
      sc_compensation_nonrating_ep_codes + sc_pension_nonrating_ep_codes
    end

    def hlr_nonrating_ep_codes
      hlr_compensation_nonrating_ep_codes + hlr_pension_nonrating_ep_codes
    end

    def nonrating_ep_codes
      sc_nonrating_ep_codes + hlr_nonrating_ep_codes
    end

    def sc_ep_codes
      sc_rating_ep_codes + sc_nonrating_ep_codes
    end

    # convert date and tiemstamp values from string to integer
    # randomize identifiers to more accurately reflect real data
    # change keys from snakecase to lower camelcase to prevent schema validation error
    def convert_and_format_message(message)
      change_supp_decision_review_type_from_hlr_to_sc(message)
      convert_dates_and_timestamps_to_int(message)
      randomize_identifiers(message)
      camelize_keys(message)
    end

    # the factorybot records used throughout this file represent a deserialized message containing
    # dates and timestamps as a string
    # the records must be altered after they're built to represent the message prior to deserialization which includes
    # date and timestamp values as an integer
    def convert_dates_and_timestamps_to_int(message)
      convert_decision_review_created_attrs(message)

      message.decision_review_issues.each do |issue|
        convert_decision_review_issue_attrs(issue)
      end

      message
    end

    # keys in the arrays contain dates and timestamps as strings
    # to be encoded, they must be converted to date logical type and milliseconds
    def convert_decision_review_created_attrs(message)
      convert_drc_dates(message)
      convert_drc_timestamps(message)
    end

    def convert_drc_dates(message)
      key_with_date_value = %w[claim_received_date]
      convert_value_to_date_logical_type(key_with_date_value, message)

      message
    end

    def convert_drc_timestamps(message)
      keys_with_timestamp_value = %w[intake_creation_time claim_creation_time]
      convert_value_to_timestamp_ms(keys_with_timestamp_value, message)

      message
    end

    def convert_value_to_date_logical_type(array_of_keys_with_date_value, object)
      array_of_keys_with_date_value.each do |key|
        convert_to_date_logical_type(key, object)
      end
    end

    def convert_value_to_timestamp_ms(array_of_keys_with_timestamp_value, message)
      array_of_keys_with_timestamp_value.each do |key|
        convert_to_timestamp_ms(key, message)
      end
    end

    # the key in the array contains a dates as a string
    # to be encoded, it must be converted to date logical type
    def convert_decision_review_issue_attrs(issue)
      key_with_date_value = %w[prior_decision_notification_date]
      convert_value_to_date_logical_type(key_with_date_value, issue)
    end

    # the factorybot objs used throughout this file represent a deserialized message containing dates as a string
    # the objs must be altered post-build to represent the message prior to deserialization which includes
    # date values as date logical type instead of a string
    # before deserialization example: 19_954 (method converts the value to this)
    # after deserialization example: "2026-05-03" (method converts the value from this)
    def convert_to_date_logical_type(key, object)
      set_value(key, object, date_string_converted_to_logical_type(key, object)) if !!object.send(key)
    end

    # converts string dates e.g. "2026-05-03" into date logical type e.g. 19_954
    def date_string_converted_to_logical_type(key, object)
      Date.parse(object.send(key)).to_time.to_i / (60 * 60 * 24)
    end

    # the factorybot objs used throughout this file represent a deserialized message containing timestamps as a string
    # the objs must be altered post-build to represent the message prior to deserialization which includes
    # timestamp values as an integer in milliseconds instead of a string
    # before deserialization example: 1_710_341_251_000 (method converts values to this)
    # after deserialization example: "2024-03-13T15:04:36.000Z" (method converts values from this)
    def convert_to_timestamp_ms(key, object)
      set_value(key, object, timestamp_string_converted_to_timestamp_ms(key, object)) if !!object.send(key)
    end

    # the object variable could be a DecisionReviewCreated or DecisionReviewIssue instance
    # key represents a given attribute within a DecisionReviewCreated or DecisionReviewIssues isntance
    # this method overrides a factorybot attribute by setting the value to a date or timestamp converted to an integer,
    # or a generated unique identifier
    def set_value(key, object, converted_value)
      object.send("#{key}=", converted_value)
    end

    # converts string timestamps e.g. "2024-03-13T15:04:36.000Z" into milliseconds e.g. 1_710_341_251_000
    def timestamp_string_converted_to_timestamp_ms(key, object)
      DateTime.parse(object.send(key)).to_i * 1000
    end

    # remove file numbers from cache to generate AppealsConsumer::Error::BisVeteranNotFound error
    def remove_file_numbers_from_cache
      @file_numbers_to_remove_from_cache.each { |file_num| Fakes::PersistentStore.cache_store.redis.del(file_num) }
    end

    # assign a random integer to any field that would expect to have a unique identifier
    def randomize_identifiers(message)
      message.decision_review_issues.each do |issue|
        randomize_decision_review_issue_identifiers(issue)
      end
    end

    # assign a random integer to the keys listed in the array
    def randomize_decision_review_issue_identifiers(issue)
      unique_identifier_keys =
        %w[contention_id prior_rating_decision_id prior_decision_rating_disability_sequence_number
           prior_non_rating_decision_id associated_caseflow_decision_id associated_caseflow_request_issue_id
           legacy_appeal_issue_id]

      unique_identifier_keys.each { |key| randomize_value(key, issue) }
    end

    # change decision_review_type to "SUPPLEMENTAL_CLAIM" if issue is a supplemental
    def change_supp_decision_review_type_from_hlr_to_sc(message)
      change_decision_review_type_to_sc(message) if sc_issue?(message.ep_code)
    end

    def change_decision_review_type_to_sc(message)
      message.decision_review_type = "SUPPLEMENTAL_CLAIM"
    end

    # after randomizing value, file number gets set to an integer so it must be converted back to a string
    def convert_file_number_to_string(message)
      message.file_number = message.file_number.to_s
    end

    # unidentified issues contain a subset of all possible scenarios
    def unidentified?(issue_type)
      issue_type.include?("unidentified")
    end

    # rating decision issues contain a subset of all possible scenarios
    def rating_decision?(issue_type)
      issue_type.include?("rating_decision")
    end

    def associated_decision_issue?(issue_type)
      issue_type.include?("decision_issue_prior")
    end

    # if the key's value is not nil, assign a unique random number to the attribute to reflect real data
    def randomize_value(key, object)
      unique_six_digit_int = (SecureRandom.random_number(9e5) + 1e5).to_i
      set_value(key, object, unique_six_digit_int) if !!object.send(key)
    end

    # deep_transform_keys! doesn't work on ActiveRecord objects so they must be
    # converted to a hash before converting to lower camelcase
    def camelize_keys(message)
      hash = convert_message_to_hash(message)
      hash.deep_transform_keys! { |key| key.camelize(:lower) }
    end

    def convert_message_to_hash(message)
      json = message.to_json
      hash = JSON.parse(json)
      hash.delete("event_id")
      hash
    end

    # encode message before publishing
    def encode_message(message)
      AvroService.new.encode(message, "DecisionReviewCreated")
    end

    # publish message to the DecisionReviewCreated topic
    def publish_message(encoded_message)
      @published_messages_count ||= 0
      Karafka.producer.produce_sync(topic: "decision_review_created", payload: encoded_message)
      @published_messages_count += 1
    end
  end
  # rubocop:enable Metrics/ClassLength
end
