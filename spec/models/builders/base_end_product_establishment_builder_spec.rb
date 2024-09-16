# frozen_string_literal: true

RSpec.describe Builders::BaseEndProductEstablishmentBuilder, type: :model do
  let(:decision_review_model) { build(:decision_review_created) }
  let(:fake_child_class) { Class.new(Builders::BaseEndProductEstablishmentBuilder).new(decision_review_model) }

  describe "#calculate_last_synced_at" do
    it "raises a NotImplementedError when it is NOT defined in an inherited class" do
      expect { fake_child_class.send(:calculate_last_synced_at) }
        .to raise_error(NotImplementedError, /must implement the calculate_last_synced_at method/)
    end
  end
end
