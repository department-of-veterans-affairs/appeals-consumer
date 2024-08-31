# frozen_string_literal: true

# This class is responsible for constructing a DecisionReviewUpdated payload that will be sent to Caseflow.
class Builders::DecisionReviewUpdated::DtoBuilder < Builders::BaseDtoBuilder
  attr_reader :claim_id, :css_id, :detail_type, :station, :payload

  def initialize(decision_review_updated_event)
    MetricsService.record(
      "Build decision review updated #{decision_review_updated_event}",
      service: :dto_builder,
      name: "Builders::DecisionReviewUpdated::DtoBuilder.initialize"
    ) do
      super()
      @event_id = decision_review_updated_event.id
      @decision_review_updated = build_decision_review_updated(decision_review_updated_event.message_payload_hash)
      assign_attributes
    end
  end

  private

  def assign_attributes
    assign_from_builders
    assign_from_decision_review_updated
    assign_decision_review_updated_payload
  end

  def assign_from_builders
    begin
      @claim_review = build_decision_review_updated_claim_review
      @end_product_establishment = build_decision_review_updated_end_product_establishment
      @added_issues = build_added_request_issues
      @updated_issues = build_updated_request_issues
      @removed_issues = build_removed_request_issues
      @withdrawn_issues = build_withdrawn_request_issues
      @eligible_to_ineligible_issues = build_eligible_to_ineligible_issues
      @ineligible_to_eligible_issues = build_ineligible_to_eligible_issues
      @ineligible_to_ineligible_issues = build_ineligible_to_ineligible_issues
    rescue StandardError => error
      raise AppealsConsumer::Error::DtoBuildError,
            "Failed building from Builders::DecisionReviewUpdated::DtoBuilder: #{error.message}"
    end
  end

  def assign_from_decision_review_updated
    @claim_id = @decision_review_updated.claim_id
    @css_id = @decision_review_updated.actor_username
    @detail_type = @decision_review_updated.decision_review_type
    @station = @decision_review_updated.actor_station
  end

  def assign_decision_review_updated_payload
    @decision_review_updated_payload = validate_no_pii(build_decision_review_updated_payload)
  end

  def build_decision_review_updated(message_payload)
    Transformers::DecisionReviewUpdated.new(@event_id, message_payload)
  end

  def build_decision_review_updated_claim_review
    Builders::DecisionReviewUpdated::ClaimReviewBuilder.build(@decision_review_updated)
  end

  def build_decision_review_updated_end_product_establishment
    Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder.build(@decision_review_updated)
  end

  def build_added_request_issues
    Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_updated_request_issues
    Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_removed_request_issues
    Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_withdrawn_request_issues
    Builders::DecisionReviewUpdated::WithdrawnIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_eligible_to_ineligible_issues
    Builders::DecisionReviewUpdated::EligibleToIneligibleIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_ineligible_to_eligible_issues
    Builders::DecisionReviewUpdated::IneligibleToEligibleIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_ineligible_to_ineligible_issues
    Builders::DecisionReviewUpdated::IneligibleToIneligibleIssueCollectionBuilder.build(@decision_review_updated)
  end

  def build_decision_review_updated_payload
    {
      event_id: @event_id,
      claim_id: @claim_id,
      css_id: @css_id,
      detail_type: @detail_type,
      station: @station,
      claim_review: clean_pii(@claim_review),
      end_product_establishment: clean_pii(@end_product_establishment),
      added_issues: clean_pii(@added_issues),
      updated_issues: clean_pii(@updated_issues),
      removed_issues: clean_pii(@removed_issues),
      ineligible_to_ineligible_issues: clean_pii(@ineligible_to_ineligible_issues),
      withdrawn_issues: clean_pii(@withdrawn_issues)
    }.as_json
  end
end
