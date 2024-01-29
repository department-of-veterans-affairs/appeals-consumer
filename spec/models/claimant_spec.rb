# frozen_string_literal: true

describe Claimant do
  describe "#new" do
    subject { described_class.new }

    it "allows reader and writer access for attributes" do
      subject.payee_code = "00"
      subject.type = "VeteranClaimant"
      subject.participant_id = "123456789"
      subject.name_suffix = nil
      subject.ssn = "987654321"
      subject.date_of_birth = Date.new(2022, 1, 1)
      subject.first_name = "John"
      subject.middle_name = "Russell"
      subject.last_name = "Smith"
      subject.email = "johnrsmith@gmail.com"

      expect(subject.payee_code).to eq("00")
      expect(subject.type).to eq("VeteranClaimant")
      expect(subject.participant_id).to eq("123456789")
      expect(subject.name_suffix).to eq(nil)
      expect(subject.ssn).to eq("987654321")
      expect(subject.date_of_birth).to eq(Date.new(2022, 1, 1))
      expect(subject.first_name).to eq("John")
      expect(subject.middle_name).to eq("Russell")
      expect(subject.last_name).to eq("Smith")
      expect(subject.email).to eq("johnrsmith@gmail.com")
    end
  end
end
