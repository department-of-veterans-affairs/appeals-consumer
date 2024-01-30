# frozen_string_literal: true

describe VeteranSerializer do
  let(:veteran) { build(:veteran) }
  subject { described_class.new(veteran).attributes }

  it "serializes the attributes" do
    expect(subject).to eq(
      "participant_id" => veteran.participant_id,
      "bgs_last_synced_at" => veteran.bgs_last_synced_at,
      "closest_regional_office" => veteran.closest_regional_office,
      "date_of_death" => veteran.date_of_death,
      "date_of_death_reported_at" => veteran.date_of_death_reported_at,
      "name_suffix" => veteran.name_suffix
    )
  end
end
