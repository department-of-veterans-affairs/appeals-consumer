# frozen_string_literal: true

describe Veteran do
  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.participant_id = "123456789"
      subject.bgs_last_synced_at = nil
      subject.closest_regional_office = nil
      subject.date_of_death = Date.new(2018, 1, 1)
      subject.date_of_death_reported_at = Date.new(2018, 2, 1)
      subject.name_suffix = nil
      subject.ssn = "963852741"
      subject.file_number = "963852741"
      subject.first_name = "John"
      subject.middle_name = "Russell"
      subject.last_name = "Smith"

      expect(subject.participant_id).to eq("123456789")
      expect(subject.bgs_last_synced_at).to eq(nil)
      expect(subject.closest_regional_office).to eq(nil)
      expect(subject.date_of_death).to eq(Date.new(2018, 1, 1))
      expect(subject.date_of_death_reported_at).to eq(Date.new(2018, 2, 1))
      expect(subject.name_suffix).to eq(nil)
      expect(subject.ssn).to eq("963852741")
      expect(subject.file_number).to eq("963852741")
      expect(subject.first_name).to eq("John")
      expect(subject.middle_name).to eq("Russell")
      expect(subject.last_name).to eq("Smith")
    end
  end
end
