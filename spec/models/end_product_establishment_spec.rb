# frozen_string_literal: true

describe EndProductEstablishment do
  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.claim_date = Date.new(2022, 1, 1)
      subject.code = "030HLRR"
      subject.modifier = "030"
      subject.reference_id = "147852369"

      expect(subject.claim_date).to eq(Date.new(2022, 1, 1))
      expect(subject.code).to eq("030HLRR")
      expect(subject.modifier).to eq("030")
      expect(subject.reference_id).to eq("147852369")
    end
  end
end
