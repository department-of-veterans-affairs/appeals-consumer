# frozen_string_literal: true

# This class should be instantiated via Builders::IntakeBuilder
class Intake
  attr_accessor :started_at, :completion_started_at, :completed_at, :completion_status, :type
end