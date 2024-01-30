# frozen_string_literal: true

describe ClaimantSerializer do
  let(:claimant) { build(:claimant) }
  subject { described_class.new(claimant).serialized_attributes }

  it "serializes the attributes" do
    expect(subject).to eq(
      "payee_code" => claimant.payee_code,
      "type" => claimant.type,
      "participant_id" => claimant.participant_id,
      "name_suffix" => claimant.name_suffix
    )
  end
end
