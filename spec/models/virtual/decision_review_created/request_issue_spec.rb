# frozen_string_literal: true

describe DecisionReviewCreated::RequestIssue do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  let(:request_issue) { build(:request_issue) }

  it "allows reader and writer access for attributes" do
    expect(request_issue.benefit_type).to eq("compensation")
    expect(request_issue.contested_issue_description).to eq("service connection for migraine is denied")
    expect(request_issue.contention_reference_id).to eq("123456789")
    expect(request_issue.contested_rating_decision_reference_id).to eq(nil)
    expect(request_issue.contested_rating_issue_profile_date).to eq(Date.new(2022, 1, 1))
    expect(request_issue.contested_rating_issue_reference_id).to eq("963852741")
    expect(request_issue.contested_decision_issue_id).to eq(nil)
    expect(request_issue.decision_date).to eq(Date.new(2022, 2, 1))
    expect(request_issue.ineligible_due_to_id).to eq(nil)
    expect(request_issue.ineligible_reason).to eq(nil)
    expect(request_issue.is_unidentified).to eq(false)
    expect(request_issue.unidentified_issue_text).to eq(nil)
    expect(request_issue.ineligible_due_to_id).to eq(nil)
    expect(request_issue.ineligible_reason).to eq(nil)
    expect(request_issue.nonrating_issue_category).to eq(nil)
    expect(request_issue.nonrating_issue_description).to eq(nil)
    expect(request_issue.untimely_exemption).to eq(nil)
    expect(request_issue.untimely_exemption_notes).to eq(nil)
    expect(request_issue.vacols_id).to eq(nil)
    expect(request_issue.vacols_sequence_id).to eq(nil)
    expect(request_issue.closed_at).to eq(nil)
    expect(request_issue.closed_status).to eq(nil)
    expect(request_issue.contested_rating_issue_diagnostic_code).to eq(nil)
    expect(request_issue.ramp_claim_id).to eq("123456789")
    expect(request_issue.rating_issue_associated_at).to eq(Time.now.utc)
    expect(request_issue.type).to eq("RatingRequestIssue")
    expect(request_issue.nonrating_issue_bgs_id).to eq(nil)
  end
end
