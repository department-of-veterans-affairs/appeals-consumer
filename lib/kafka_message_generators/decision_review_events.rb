# frozen_string_literal: true

module KafkaMessageGenerators
  # rubocop:disable Metrics/ClassLength
  class DecisionReviewEvents < ::KafkaMessageGenerators::Base
    # clears the cache incase any records are currently stored
    # initializes variable that will hold file numbers to be removed from the cache
    # these file numbers will get a different bis response than the rest to test event audit notes and logging
    def initialize(decision_review_event_type)
      super()
      clear_cache
      @file_numbers_to_remove_from_cache = []
      @decision_review_event_type = decision_review_event_type
      @claim_id = 710_000_000
      @contention_id = 710_000_000
      @new_contention_id = 720_000_000
      @veteran_participant_id = "210000000"
      @claimant_participant_id = "950000000"
      @file_number = "310000000"
    end

    # creates all vbms intake scenarios for every ep code
    # including scenarios that would raise an error within appeals-consumer
    def publish_messages!
      puts "Started creating #{@decision_review_event_type} messages..."
      messages = create_messages
      puts "Finished creating messages!"

      puts "Started preparing and publishing #{messages.flatten.count} messages..."
      messages.flatten.each do |message|
        topic = ENV["#{@decision_review_event_type.upcase}_TOPIC"]
        formatted_message = convert_and_format_message(message)
        encoded_message = encode_message(formatted_message, topic)
        publish_message(encoded_message, topic)
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
      rating_messages = ep_codes.map do |code|
        create_rating_issue_type_messages(code)
      end

      ensure_messages_contain_bis_rating_profile(rating_messages)
      rating_messages
    end

    def ensure_messages_contain_bis_rating_profile(rating_messages)
      rating_messages.flatten.each do |message|
        unless should_skip_creating_bis_rating_profile?(message)
          store_issue_bis_rating_profile_without_ramp_id(message)
        end
      end
    end

    def should_skip_creating_bis_rating_profile?(message)
      rating_profile_already_in_bis?(message.veteran_participant_id) ||
        issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
          issues_dont_have_rating_identifier?(message.send(issue_type))
        end
    end

    def rating_profile_already_in_bis?(participant_id)
      Fakes::BISService.new.get_rating_record(participant_id)
    end

    def issues_dont_have_rating_identifier?(issues)
      issues.none? { |issue| !!issue.prior_rating_decision_id }
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

    # creates scenarios for messages that have a prior_rating_decision_id and prior_caseflow_decision_issue_id
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

      assoc_decision_issue_messages = create_assoc_decision_issue_messages(issue_type, code, rating_decision_messages)
      return assoc_decision_issue_messages if associated_decision_issue?(issue_type)

      eligible_with_two_issues = create_eligible_with_two_issues(issue_type, code)
      contested_with_additional_issue = create_contested_with_additional_issue(issue_type, code)

      rating_issue_messages = [eligible_with_two_issues, contested_with_additional_issue]

      assoc_decision_issue_messages + rating_issue_messages
    end

    # scenarios that exist for every issue type regardless of ep_code
    def create_unidentified_messages(issue_type, code)
      veteran_claimant = create_dre_message("eligible_#{issue_type}_veteran_claimant", code)
      non_veteran_claimant = create_dre_message("eligible_#{issue_type}_non_veteran_claimant", code)
      no_decision_date = create_dre_message("eligible_#{issue_type}_without_prior_decision_date", code)
      with_poa_access = create_dre_message_with_poa_access("eligible_#{issue_type}_veteran_claimant", code)
      without_poa_access = create_dre_message_without_poa_access("eligible_#{issue_type}_veteran_claimant", code)
      nil_poa_access = create_dre_message_with_nil_poa_access("eligible_#{issue_type}_veteran_claimant", code)

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
    def create_dre_message_with_poa_access(issue_trait, code)
      @with_poa_access_claim_id ||= 1
      dre = create_dre_message(issue_trait, code)
      set_claim_id(dre, @with_poa_access_claim_id)
      @with_poa_access_claim_id += 2

      dre
    end

    # even claim ids will have these poa values for the end product establishment record:
    # limited_poa_code: "007", limited_poa_access: "N"
    def create_dre_message_without_poa_access(issue_trait, code)
      @without_poa_access_claim_id ||= 2
      dre = create_dre_message(issue_trait, code)
      set_claim_id(dre, @without_poa_access_claim_id)
      @without_poa_access_claim_id += 2

      dre
    end

    # claim id value of 0 will return nil for the limited poa BIS call
    def create_dre_message_with_nil_poa_access(issue_trait, code)
      @nil_poa_access_claim_id ||= 0
      dre = create_dre_message(issue_trait, code)
      set_claim_id(dre, @nil_poa_access_claim_id)

      dre
    end

    def set_claim_id(dre, claim_id_int)
      dre.claim_id = claim_id_int
    end

    # scenarios that are applicable to rating decision messages
    def create_identified_messages(issue_type, code, valid_unidentified_messages)
      eligible_legacy = create_dre_message("eligible_#{issue_type}_legacy", code)
      time_override = create_dre_message("eligible_#{issue_type}_time_override", code)

      [eligible_legacy, time_override] + valid_unidentified_messages
    end

    def bis_rating_profile_with_ramp(issue, message)
      {
        rba_issue_list: {
          rba_issue: {
            rba_issue_id: issue.prior_rating_decision_id,
            prfil_date: issue.prior_decision_rating_profile_date&.to_date
          }
        },
        rba_claim_list: {
          rba_claim: {
            bnft_clm_tc: "682HLRRRAMP",
            clm_id: message.claim_id,
            prfl_date: issue.prior_decision_rating_profile_date&.to_date
          }
        },
        response: {
          response_text: "Success"
        }
      }
    end

    def bis_rating_profile_no_data
      {
        response: {
          response_text: "No Data Found"
        }
      }
    end

    def create_with_ramp_claim_id(issue_type, code)
      dre = create_dre_message("eligible_#{issue_type}_veteran_claimant", code)
      store_bis_rating_profiles_with_ramp_id(dre)
      dre
    end

    def store_bis_rating_profiles_with_ramp_id(message)
      issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
        message.send(issue_type).each do |issue|
          store_bis_rating_profiles(message, bis_rating_profile_with_ramp(issue, message))
        end
      end
    end

    def create_with_no_data_found(issue_type, code)
      dre = create_dre_message("eligible_#{issue_type}_veteran_claimant", code)
      store_bis_rating_profiles(dre, bis_rating_profile_no_data)
      dre
    end

    # scenarios that are applicable to rating issues with or without an associated caseflow decision id
    def create_assoc_decision_issue_messages(issue_type, code, rating_decision_messages)
      bis_with_ramp_id = create_with_ramp_claim_id(issue_type, code)
      bis_no_data_found = create_with_no_data_found(issue_type, code)

      rating_decision_messages + [bis_with_ramp_id, bis_no_data_found]
    end

    def store_bis_rating_profiles(message, bis_record)
      Fakes::RatingStore.new
        .store_rating_profile_record(message.veteran_participant_id, bis_record)
    end

    # unidentified issues have different invalid scenarios from identified messages
    def create_invalid_messages(issue_type, code)
      invalid_unidentified_messages = create_invalid_unidentified_messages(issue_type, code)
      return invalid_unidentified_messages if unidentified?(issue_type)

      invalid_identified_messages = create_invalid_identified_messages(issue_type, code, invalid_unidentified_messages)
      return invalid_identified_messages if rating_decision?(issue_type) || associated_decision_issue?(issue_type)

      contested_issue = create_contested_issue(issue_type, code)

      invalid_identified_messages + contested_issue
    end

    def create_contested_issue(issue_type, code)
      dre = create_dre_message("ineligible_#{issue_type}_contested", code)

      [dre]
    end

    # scenarios that pertain to unidentified issues
    def create_invalid_unidentified_messages(issue_type, code)
      eligible_without_contention_id = create_dre_message("eligible_#{issue_type}_without_contention_id", code)
      bis_veteran_not_found = create_dre_message_and_track_file_number("eligible_#{issue_type}", code)
      bis_person_not_found =
        create_dre_message_without_bis_person("eligible_#{issue_type}_veteran_claimant", code)

      [
        eligible_without_contention_id,
        bis_veteran_not_found,
        bis_person_not_found
      ]
    end

    # message scenarios that pertain to identified rating decisions and rating issues
    # with or without an associated caseflow decision id
    def create_invalid_identified_messages(issue_type, code, invalid_unidentified_messages)
      pending_hlr_without_ri_id = create_dre_message("ineligible_#{issue_type}_pending_hlr_without_ri_id", code)
      ineligible_with_contention_id = create_dre_message("ineligible_#{issue_type}_with_contention_id", code)

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
      untimely = create_dre_message("ineligible_#{issue_type}_time_restriction_untimely", code)
      before_ama = create_dre_message("ineligible_#{issue_type}_time_restriction_before_ama", code)
      no_soc_ssoc = create_dre_message("ineligible_#{issue_type}_no_soc_ssoc", code)
      pending_legacy_appeal =
        create_dre_message("ineligible_#{issue_type}_pending_legacy_appeal", code)
      legacy_time_restriction =
        create_dre_message("ineligible_#{issue_type}_legacy_time_restriction", code)
      pending_hlr = create_dre_message("ineligible_#{issue_type}_pending_hlr", code)
      pending_board = create_dre_message("ineligible_#{issue_type}_pending_board_appeal", code)
      pending_supplemental = create_dre_message("ineligible_#{issue_type}_pending_supplemental", code)

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
      completed_hlr = create_dre_message("ineligible_#{issue_type}_completed_hlr", code)
      completed_board = create_dre_message("ineligible_#{issue_type}_completed_board_appeal", code)

      [completed_hlr, completed_board] + ineligible_supp_messages
    end

    # create the message, increment the file number, and add it to array that will test
    # logging and event audit notes column
    def create_dre_message_and_track_file_number(issue_trait, code)
      dre = create_dre_message(issue_trait, code)
      @file_numbers_to_remove_from_cache << dre.file_number
      dre
    end

    # if a claimant_participant_id is "", the fake BIS call with return an empty obj
    # tests logging and event audit notes column
    def create_dre_message_without_bis_person(issue_trait, code)
      dre = create_dre_message(issue_trait, code)
      dre.claimant_participant_id = ""
      dre
    end

    # represents a message post-consumption and post-deserialization
    # some fields must be changed to accurately reflect a message prior to consumption
    def create_dre_message(trait, ep_code)
      dre = FactoryBot.build(@decision_review_event_type.to_sym, trait.to_sym, ep_code: ep_code)
      update_claim_id(dre)
      store_veteran_in_cache(dre)
      dre
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

    # creates scenarios for messages that have a prior_nonrating_decision_id and prior_caseflow_decision_issue_id
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
      return identified_messages if associated_decision_issue?(issue_type)

      decision_type_messages = create_decision_type_messages(issue_type, code)
      eligible_with_two_issues = create_eligible_with_two_issues(issue_type, code)
      contested_with_additional_issue = create_contested_with_additional_issue(issue_type, code)
      decision_source_message = create_decision_source_message(issue_type, code)

      identified_messages + decision_type_messages + eligible_with_two_issues + contested_with_additional_issue +
        decision_source_message
    end

    def create_eligible_with_two_issues(issue_type, code)
      dre = create_dre_message("eligible_#{issue_type}_with_two_issues", code)

      [dre]
    end

    def create_contested_with_additional_issue(issue_type, code)
      dre = create_dre_message("ineligible_#{issue_type}_contested_with_additional_issue", code)

      [dre]
    end

    def create_decision_source_message(issue_type, code)
      dre = create_dre_message("eligible_#{issue_type}_with_decision_source", code)

      [dre]
    end

    def store_issue_bis_rating_profile_without_ramp_id(message)
      issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
        message.send(issue_type).each do |issue|
          store_bis_rating_profiles(message, bis_rating_profile_without_ramp(issue, message))
        end
      end
    end

    def bis_rating_profile_without_ramp(issue, message)
      {
        rba_issue_list: {
          rba_issue: {
            rba_issue_id: issue.prior_rating_decision_id,
            prfil_date: issue.prior_decision_rating_profile_date&.to_date
          }
        },
        rba_claim_list: {
          rba_claim: {
            bnft_clm_tc: message.ep_code,
            clm_id: message.claim_id,
            prfl_date: issue.prior_decision_rating_profile_date&.to_date
          }
        },
        response: {
          response_text: "Success"
        }
      }
    end

    def create_decision_type_messages(issue_type, code)
      NONRATING_DECISION_TYPES.map do |decision_type|
        dre = create_dre_message("eligible_#{issue_type}_veteran_claimant", code)
        change_issue_decision_type_and_decision_text(dre, decision_type)
        dre
      end
    end

    def change_issue_decision_type_and_decision_text(dre, decision_type)
      issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
        dre.send(issue_type).each do |issue|
          issue.prior_decision_type = decision_type
          issue.prior_decision_text = "#{decision_type}: Service connection for tetnus denied"
        end
      end
      dre
    end

    # set claim_id to a incremented value
    def update_claim_id(dre)
      dre.claim_id = update_value("claim_id", dre)
    end

    # store veteran record in Fakes::VeteranStore for all messages
    # rubocop:disable Metrics/MethodLength
    def store_veteran_in_cache(dre)
      veteran_bis_record =
        {
          file_number: dre.file_number,
          ptcpnt_id: dre.veteran_participant_id,
          sex: "M",
          first_name: dre.veteran_first_name,
          middle_name: "Russell",
          last_name: dre.veteran_last_name,
          name_suffix: "II",
          ssn: Faker::IDNumber.valid.delete("-"),
          addreess_line1: "122 Mullberry St.",
          addreess_line2: "PO BOX 123",
          addreess_line3: "Daisies",
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

      Fakes::VeteranStore.new.store_veteran_record(dre.file_number, veteran_bis_record)
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
    # change keys from snakecase to lower camelcase to prevent schema validation error
    def convert_and_format_message(message)
      change_supp_decision_review_type_from_hlr_to_sc(message)
      convert_dates_and_timestamps_to_int(message)
      camelize_keys(message)
    end

    # the factorybot records used throughout this file represent a deserialized message containing
    # dates and timestamps as a string
    # the records must be altered after they're built to represent the message prior to deserialization which includes
    # date and timestamp values as an integer
    def convert_dates_and_timestamps_to_int(message)
      convert_decision_review_created_attrs(message)

      issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
        message.send(issue_type).each do |issue|
          convert_decision_review_issue_attrs(issue)
        end
      end

      message
    end

    # keys in the arrays contain dates and timestamps as strings
    # to be encoded, they must be converted to date logical type and milliseconds
    def convert_decision_review_created_attrs(message)
      convert_dre_dates(message)
      convert_dre_timestamps(message)
    end

    def convert_dre_dates(message)
      key_with_date_value = %w[claim_received_date]
      convert_value_to_date_logical_type(key_with_date_value, message)

      message
    end

    def convert_dre_timestamps(message)
      keys_with_timestamp_value =
        if decision_review_updated?
          %w[claim_creation_time update_time]
        else
          %w[intake_creation_time claim_creation_time]
        end
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
      key_with_date_value = %w[prior_decision_date prior_decision_notification_date]
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
      if decision_review_updated?
        object.send(key).to_time.to_i / (60 * 60 * 24)
      else
        Date.parse(object.send(key)).to_time.to_i / (60 * 60 * 24)
      end
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

    # change bis response for veteran profile to test event audit notes and logging
    def change_veteran_bis_response
      @file_numbers_to_remove_from_cache.each { |file_num| Fakes::PersistentStore.cache_store.redis.del(file_num) }
      veteran_bis_record = { ptcpnt_id: nil }

      @file_numbers_to_remove_from_cache.each do |file_num|
        Fakes::VeteranStore.new.store_veteran_record(file_num, veteran_bis_record)
      end
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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def update_value(key, object)
      veteran_claimant = object.veteran_participant_id == object.claimant_participant_id

      object.claim_id = @claim_id
      issue_types.fetch(@decision_review_event_type.to_sym, []).each do |issue_type|
        next if object.send(issue_type).empty?

        if decision_review_updated? && issue_type == :decision_review_issues_created &&
           object.send(:decision_review_issues_created)[0].contention_action == "ADD_CONTENTION"
          object.send(issue_type)[0].contention_id = @new_contention_id
          @new_contention_id += 1
        elsif decision_review_updated? && issue_type == :decision_review_issues_created &&
              object.send(:decision_review_issues_created)[0].contention_action == "NONE"
          object.send(issue_type)[0].contention_id = nil
        else
          object.send(issue_type)[0].contention_id = @contention_id
          @contention_id += 1
        end
      end
      object.veteran_participant_id = @veteran_participant_id
      object.claimant_participant_id = veteran_claimant ? @veteran_participant_id : @claimant_participant_id
      object.file_number = @file_number
      @claim_id += 1
      @veteran_participant_id = @veteran_participant_id.next
      @claimant_participant_id = @claimant_participant_id.next
      @file_number = @file_number.next

      object.send(key)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
  end
  # rubocop:enable Metrics/ClassLength
end
