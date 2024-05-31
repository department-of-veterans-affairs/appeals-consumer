# frozen_string_literal: true

# This class is ultimately responsible for constructing a DecisionReviewCompleted payload
# that will be sent to Caseflow.
class Builders::DecisionReviewCompleted::DtoBuilder < Builders::BaseDtoBuilder
  attr_reader :payload

  def initialize(drc_event)
    @event_id = drc_event.id
    @decision_review_completed = build_decision_review_completed(drc_event.message_payload_hash)
    assign_attributes
  end

  private

  def build_decision_review_completed(message_payload)
    Transformers::DecisionReviewCompleted.new(@event_id, message_payload)
  end
  
  def assign_attributes
    assign_from_builders
    assign_payload
  end

  def assign_from_builders
    begin
      @end_product_establishment = build_end_product_establishment
      @claim_review = build_claim_review
      @request_issues = build_request_issues
      @decision_issues = build_decision_issues
    rescue StandardError => error
      raise AppealsConsumer::Error::DtoBuildError, "Failed building from Builders::DecisionReviewCompleted::DtoBuilder:
      #{error.message}"
    end
  end

  # scrubs payload from any PII
  def assign_payload
    @payload = validate_no_pii(build_payload)
  end

  def build_end_product_establishment
    Builders::DecisionReviewCompleted::EndProductEstablishmentBuilder.build(@decision_review_completed)
  end

  def build_claim_review
    Builders::DecisionReviewCompleted::ClaimReviewBuilder.build(@decision_review_completed)
  end

  def build_request_issues
    Builders::DecisionReviewCompleted::RequestIssueBuilder.build(@decision_review_completed)
  end

  def build_decision_issues
    Builders::DecisionReviewCompleted::DecisionIssueBuilder.build(@decision_review_completed)
  end

  def build_payload
    {
      "event_id": @event_id,
      "end_product_establishment": clean_pii(@end_product_establishment),
      "claim_review": clean_pii(@claim_review),
      "request_issues": clean_pii(@request_issues),
      "decision_issues": clean_pii(@decision_issues)
    }.as_json
  end

end