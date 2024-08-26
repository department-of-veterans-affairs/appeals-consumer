# frozen_string_literal: true

# This class is used to build out an DecisionReviewCreated::Intake object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::IntakeBuilder
  include DecisionReview::ModelBuilderHelper
  attr_reader :intake, :decision_review_model

  COMPLETION_SUCCESS_STATUS = "success"

  def self.build(decision_review_model)
    builder = new(decision_review_model)
    builder.assign_attributes
    builder.intake
  end

  def initialize(decision_review_model)
    @decision_review_model = decision_review_model
    @intake = DecisionReviewCreated::Intake.new
  end

  # :reek:TooManyStatements
  def assign_attributes
    calculate_started_at
    calculate_completion_started_at
    calculate_completed_at
    assign_completion_status
    calculate_type
    calculate_detail_type
  end

  private

  def calculate_started_at
    @intake.started_at = convert_to_timestamp_ms(@decision_review_model.intake_creation_time)
  end

  def calculate_completion_started_at
    @intake.completion_started_at = claim_creation_time_converted_to_timestamp_ms
  end

  def calculate_completed_at
    @intake.completed_at = claim_creation_time_converted_to_timestamp_ms
  end

  def assign_completion_status
    @intake.completion_status = COMPLETION_SUCCESS_STATUS
  end

  def calculate_type
    decision_review_type = @decision_review_model.decision_review_type
    if decision_review_type == "HIGHER_LEVEL_REVIEW"
      @intake.type = "HigherLevelReviewIntake"
    elsif decision_review_type == "SUPPLEMENTAL_CLAIM"
      @intake.type = "SupplementalClaimIntake"
    end
  end

  def calculate_detail_type
    decision_review_type = @decision_review_model.decision_review_type
    if decision_review_type == "HIGHER_LEVEL_REVIEW"
      @intake.detail_type = "HigherLevelReview"
    elsif decision_review_type == "SUPPLEMENTAL_CLAIM"
      @intake.detail_type = "SupplementalClaim"
    end
  end
end
