# frozen_string_literal: true

# This class is used to build out an Intake object from an instance of DecisionReviewCreated
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

  def assign_attributes
    assign_started_at
    assign_completion_started_at
    assign_completed_at
    assign_completion_status
    calculate_type
  end

  private

  def assign_started_at; end

  def assign_completion_started_at; end

  def assign_completed_at; end

  # always "success"
  def assign_completion_status; end

  def calculate_type; end
end
