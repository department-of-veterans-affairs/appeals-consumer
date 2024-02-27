# frozen_string_literal: true

class DecisionReviewCreatedJob < BaseProcessingJob
  queue_as :high_priority
#   transaction do
#     event.in_progress!# event.update(state: "IN_PROGRESS")
#     ea = EventAudit.create(event: event)
#   end

#   Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.process!(event)
#   transaction do
#     ea.completed! # ea.update(status: "COMPLETED")
#     event.processed!# event.update(state: "PROCESSED")
#   end

# rescue StandardError => error

#   transaction do
#     ea.failed!(error.message) # ea.update(error: error.message, status: "FAILED")
#     event.handle_failure!
#     #event.failed? ? event.failed! : event.error! # event.update(state: "FAILED") : event:update(state: "ERROR")
#   end

#   Rails.logger.error(error)
end
