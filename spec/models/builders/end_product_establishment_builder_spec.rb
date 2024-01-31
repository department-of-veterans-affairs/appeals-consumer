# frozen_string_literal: true

describe Builders::EndProductEstablishmentBuilder do
  describe "#build" do
    let!(:decision_review_created) { build(:decision_review_created) }
    subject { described_class.build(decision_review_created) }

    it "returns an EndProductEstablishment object" do
      expect(subject).to be_an_instance_of(EndProductEstablishment)
    end
  end

  describe "#initialize" do
    let(:builder) { described_class.new }
    let(:epe) { described_class.new.end_product_establishment }

    it "initializes a new EndProductEstablishmentBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new EndProductEstablishment object" do
      expect(epe).to be_an_instance_of(EndProductEstablishment)
    end
  end
end
