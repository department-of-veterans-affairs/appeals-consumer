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
  class BisVeteranNotFound < StandardError; end
  class BisClaimantNotFound < StandardError; end
  class NullContentionIdError < StandardError; end
  class NullPriorDecisionNotificationDate < StandardError; end
  class NullAssociatedCaseflowRequestIssueId < StandardError; end
  class IssueEligibilityResultNotRecognized < StandardError; end
  class NoIssuesFound < StandardError; end
  class NotNullContentionIdError < StandardError; end
end
