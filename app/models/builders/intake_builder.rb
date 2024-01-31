# frozen_string_literal: true

# This class is used to build out an Intake object from an instance of DecisionReviewCreated
class Builders::IntakeBuilder
  attr_reader :intake

  def self.build(decision_review_created)
    builder = new
    builder.assign_attributes(decision_review_created)
    builder.intake
  end

  def initialize
    @intake = Intake.new
  end

  def assign_attributes(decision_review_created)
    assign_started_at(decision_review_created)
    assign_completion_started_at(decision_review_created)
    assign_completed_at(decision_review_created)
    assign_completion_status
    calculate_type(decision_review_created)
  end

  private

  def assign_started_at(decision_review_created); end

  def assign_completion_started_at(decision_review_created); end

  def assign_completed_at(decision_review_created); end

  # always "success"
  def assign_completion_status; end

  def calculate_type(decision_review_created); end
end
