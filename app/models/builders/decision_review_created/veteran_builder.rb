# frozen_string_literal: true

# This class is used to build out a DecisionReviewCreated::Veteran object from an instance of DecisionReviewCreated
class Builders::DecisionReviewCreated::VeteranBuilder < Builders::BaseVeteranBuilder
  def initialize(decision_review_model)
    @veteran = DecisionReviewCreated::Veteran.new
    super
  end
end
