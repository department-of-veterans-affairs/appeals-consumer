# frozen_string_literal: true

describe ClaimReview do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  let(:claim_review) { build(:claim_review) }

  it "allows reader and writer access for attributes" do
    expect(claim_review.filed_by_va_gov).to eq(true)
    expect(claim_review.receipt_date).to eq(Time.now.utc)
    expect(claim_review.legacy_opt_in_approved).to eq(true)
    expect(claim_review.informal_conference).to eq(true)
    expect(claim_review.same_office).to eq(true)
  end
end
