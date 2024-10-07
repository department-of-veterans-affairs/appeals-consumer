# frozen_string_literal: true

describe Events::DecisionReviewCompletedEvent, type: :model do
  let(:event) { Events::DecisionReviewCompletedEvent.new }

  describe "#process!" do
    it "responds to process! method" do
      expect(event).to respond_to(:process!)
    end
  end
end
