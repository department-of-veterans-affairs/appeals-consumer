# frozen_string_literal: true

describe ClaimReview do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
  end

  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.filed_by_va_gov = true
      subject.receipt_date = Time.now.utc
      subject.legacy_opt_in_approved = true
      subject.higher_level_review = true
      subject.informal_conference = true
      subject.same_office = true

      expect(subject.filed_by_va_gov).to eq(true)
      expect(subject.receipt_date).to eq(Time.now.utc)
      expect(subject.legacy_opt_in_approved).to eq(true)
      expect(subject.higher_level_review).to eq(true)
      expect(subject.informal_conference).to eq(true)
      expect(subject.same_office).to eq(true)
    end
  end
end
