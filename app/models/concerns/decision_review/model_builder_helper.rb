# frozen_string_literal: true

# This module is to encapsulate common functionanlity amungst the individiual
# model builder classes such as Builders::DecisionReviewCreated::EndProductEstablishment
# rubocop:disable Metrics/ModuleLength
module DecisionReview::ModelBuilderHelper
  # used to convert date type to date logical type
  EPOCH_DATE = Date.new(1970, 1, 1)
  PENSION_IDENTIFIER = "PMC"
  PENSION_BENEFIT_TYPE = "pension"
  COMPENSATION_BENEFIT_TYPE = "compensation"

  def fetch_veteran_bis_record
    return unless @decision_review_model

    begin
      bis_record = BISService.new.fetch_veteran_info(@decision_review_model.file_number)
    rescue StandardError => error
      log_msg_and_update_current_event_audit_notes!(error.message, error: true)
    end

    # If the participant id is nil, that's another way of saying the veteran wasn't found
    unless bis_record&.dig(:ptcpnt_id)
      msg = "BIS Veteran: Veteran record not found for DecisionReviewCreated file_number:"\
       " #{@decision_review_model.file_number}"
      log_msg_and_update_current_event_audit_notes!(msg)
    end

    @bis_synced_at = Time.zone.now
    bis_record
  end

  def fetch_limited_poa
    return unless @decision_review_model

    begin
      limited_poa = BISService.new.fetch_limited_poas_by_claim_ids(@decision_review_model.claim_id)
    rescue StandardError => error
      log_msg_and_update_current_event_audit_notes!(error.message, error: true)
    end

    limited_poa ? limited_poa[@decision_review_model.claim_id] : nil
  end

  def fetch_person_bis_record
    begin
      bis_record = BISService.new.fetch_person_info(@decision_review_model.claimant_participant_id)
    rescue StandardError => error
      log_msg_and_update_current_event_audit_notes!(error.message, error: true)
    end

    # If the result is empty, the claimant wasn't found
    if bis_record.blank?
      msg = "BIS Person: Person record not found for DecisionReviewCreated claimant_participant_id:"\
       " #{@decision_review_model.claimant_participant_id}"
      log_msg_and_update_current_event_audit_notes!(msg)
    end

    bis_record
  end

  def fetch_bis_rating_profiles
    return unless @decision_review_model && @earliest_issue_profile_date && @latest_issue_profile_date_plus_one_day

    begin
      @bis_rating_profiles_record = BISService.new.fetch_rating_profiles_in_range(
        participant_id: @decision_review_model.veteran_participant_id,
        start_date: @earliest_issue_profile_date,
        end_date: @latest_issue_profile_date_plus_one_day
      )
    rescue StandardError => error
      log_msg_and_update_current_event_audit_notes!(error.message, error: true)
    end

    # log bis_record response if the response_text is anything other than "success"
    if downcase_bis_rating_profiles_response_text != "success"
      msg = "BIS Rating Profiles: Rating Profile info not found for DecisionReviewCreated veteran_participant_id"\
        " #{@decision_review_model.veteran_participant_id} within the date range #{earliest_issue_profile_date}"\
        " - #{latest_issue_profile_date_plus_one_day}."

      log_msg_and_update_current_event_audit_notes!(msg)
    end

    @bis_rating_profiles_record
  end

  def convert_to_date_logical_type(value)
    Date.parse(value).to_time.to_i / (60 * 60 * 24) if !!value
  end

  def convert_to_timestamp_ms(value)
    DateTime.parse(value).to_i * 1000 if !!value
  end

  def claim_creation_time_converted_to_timestamp_ms
    return unless @decision_review_model

    convert_to_timestamp_ms(@decision_review_model.claim_creation_time)
  end

  # updated time is NOT present on DecisionReviewCreated events
  def update_time_converted_to_timestamp_ms
    return unless @decision_review_model

    convert_to_timestamp_ms(@decision_review_model.update_time)
  end

  private

  def downcase_bis_rating_profiles_response_text
    @bis_rating_profiles_record&.dig(:response, :response_text)&.downcase
  end

  def log_msg_and_update_current_event_audit_notes!(msg, error: false)
    log_msg(msg, error)
    update_event_audit_notes!(msg)
  end

  def log_msg(msg, error)
    error ? log_error(msg) : log_info(msg)
  end

  def logger
    LoggerService.new(self.class.name)
  end

  def log_info(msg)
    logger.info(msg)
  end

  def log_error(msg)
    logger.error(msg)
  end

  def update_event_audit_notes!(msg)
    event = Event.find(@decision_review_model.event_id)
    last_event_audit = event.event_audits.where(status: :in_progress)&.last

    last_event_audit&.update!(notes: event_audit_concatenated_notes(last_event_audit, msg))
  end

  def event_audit_concatenated_notes(last_event_audit, msg)
    custom_note = "Note #{Time.zone.now}: #{msg}"
    return custom_note if last_event_audit.notes.nil?

    "#{last_event_audit.notes} - #{custom_note}"
  end
end
# rubocop:enable Metrics/ModuleLength
