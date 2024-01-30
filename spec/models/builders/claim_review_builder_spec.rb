# frozen_string_literal: true

describe Builders::ClaimReviewBuilder do
  describe "#new" do
    subject { described_class.new }
    it "creates an instance of the class" do
      expect(subject).to be_an_instance_of(described_class)
    end
  end
end
