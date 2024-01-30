# frozen_string_literal: true

RSpec.describe Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent, type: :model do
  describe "#self.process!(event)" do
    let!(:event) { create(:event) }
    subject { Topics::DecisionReviewCreatedTopic::DecisionReviewCreatedEvent.process!(event) }

    it "does not raise an error when called" do
      expect { subject }.not_to raise_error
    end
  end
end
