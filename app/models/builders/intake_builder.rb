# frozen_string_literal: true

# This class is used to build out an Intake object from an instance of DecisionReviewCreated
# :reek:TooManyInstanceVariables
class Builders::IntakeBuilder
  attr_reader :intake, :decision_review_created

  def self.build(decision_review_created)
    builder = new(decision_review_created)
    builder.assign_attributes
    builder.intake
  end

  def initialize(decision_review_created)
    @decision_review_created = decision_review_created
    @intake = Intake.new
  end

  # :reek:TooManyStatements
  def assign_attributes
    assign_started_at
    assign_completion_started_at
    assign_completed_at
    assign_completion_status
    calculate_type
    calculate_detail_type
  end

  private

  def assign_started_at
    @intake.started_at = @decision_review_created.intake_creation_time
  end

  def assign_completion_started_at
    @intake.completion_started_at = @decision_review_created.claim_creation_time
  end

  def assign_completed_at
    @intake.completed_at = @decision_review_created.claim_creation_time
  end

  def assign_completion_status
    @intake.completion_status = "success"
  end

  def calculate_type
    decision_review_type = @decision_review_created.decision_review_type
    if decision_review_type == "HigherLevelReview"
      @intake.type = "HigherLevelReviewIntake"
    elsif decision_review_type == "SupplementalClaim"
      @intake.type = "SupplementalClaimIntake"
    end
  end

  def calculate_detail_type
    decision_review_type = @decision_review_created.decision_review_type
    if decision_review_type == "HigherLevelReview"
      @intake.detail_type = "HigherLevelReview"
    elsif decision_review_type == "SupplementalClaim"
      @intake.detail_type = "SupplementalClaim"
    end
  end
end
