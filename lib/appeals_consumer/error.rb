# frozen_string_literal: true

module AppealsConsumer::Error
  module ErrorSerializer
    extend ActiveSupport::Concern

    def initialize(args)
      @code = args[:code]
      @message = args[:message]
      @title = args[:title]
    end
  end

  class SerializableError < StandardError
    include AppealsConsumer::Error::ErrorSerializer
    attr_accessor :code, :message, :title, :actionable, :application
  end

  class CaseflowError < SerializableError; end
  class ClientRequestError < CaseflowError; end
  class NullContentionIdError < StandardError; end
  class NullPriorDecisionDate < StandardError; end
  class NullAssociatedCaseflowRequestIssueId < StandardError; end
  class IssueEligibilityResultNotRecognized < StandardError; end
  class RequestIssueCollectionBuildError < StandardError; end
  class RequestIssueBuildError < StandardError; end
  class NotNullContentionIdError < StandardError; end
  class BisLimitedPoaError < StandardError; end
  class BisVeteranError < StandardError; end
  class BisPersonError < StandardError; end
  class BisRatingProfilesError < StandardError; end
  # Custom error specifically for PII existance in payload hashes
  class PIIFoundViolationError < StandardError; end
  # Custom error specifically for build errors
  class DtoBuildError < StandardError; end
  class EventConsumptionError < StandardError; end
  class PriorDecisionReviewEventsStillPendingError < StandardError; end
end
