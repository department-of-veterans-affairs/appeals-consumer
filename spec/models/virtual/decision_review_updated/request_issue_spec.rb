# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

describe DecisionReviewUpdated::RequestIssue do
  include_context "decision_review_updated_context"
  let(:event_id) { 11_917 }
  let(:decision_review_updated_model) { Transformers::DecisionReviewUpdated.new(event_id, message_payload) }
  let(:issue) { decision_review_updated_model.decision_review_issues_created.first }
  let(:bis_rating_profiles) { nil }
  let(:request_issue) do
    Builders::DecisionReviewUpdated::RequestIssueBuilder.build(
      issue,
      decision_review_updated_model,
      bis_rating_profiles
    )
  end

  it "allows reader and writer access for attributes" do
    expect(request_issue).to respond_to(:contested_issue_description)
    expect(request_issue).to respond_to(:contention_reference_id)
    expect(request_issue).to respond_to(:contested_rating_decision_reference_id)
    expect(request_issue).to respond_to(:contested_rating_issue_profile_date)
    expect(request_issue).to respond_to(:contested_rating_issue_reference_id)
    expect(request_issue).to respond_to(:contested_decision_issue_id)
    expect(request_issue).to respond_to(:decision_date)
    expect(request_issue).to respond_to(:ineligible_due_to_id)
    expect(request_issue).to respond_to(:is_unidentified)
    expect(request_issue).to respond_to(:unidentified_issue_text)
    expect(request_issue).to respond_to(:nonrating_issue_category)
    expect(request_issue).to respond_to(:ineligible_reason)
    expect(request_issue).to respond_to(:nonrating_issue_description)
    expect(request_issue).to respond_to(:untimely_exemption)
    expect(request_issue).to respond_to(:untimely_exemption_notes)
    expect(request_issue).to respond_to(:vacols_id)
    expect(request_issue).to respond_to(:vacols_sequence_id)
    expect(request_issue).to respond_to(:benefit_type)
    expect(request_issue).to respond_to(:closed_at)
    expect(request_issue).to respond_to(:closed_status)
    expect(request_issue).to respond_to(:contested_rating_issue_diagnostic_code)
    expect(request_issue).to respond_to(:ramp_claim_id)
    expect(request_issue).to respond_to(:rating_issue_associated_at)
    expect(request_issue).to respond_to(:type)
    expect(request_issue).to respond_to(:nonrating_issue_bgs_id)
    expect(request_issue).to respond_to(:nonrating_issue_bgs_source)
    expect(request_issue).to respond_to(:decision_review_issue_id)
  end
end