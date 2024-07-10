# frozen_string_literal: true

describe Events::DecisionReviewUpdatedEvent, type: :model do
  let(:event) { Events::DecisionReviewUpdatedEvent.new }

  describe "#process!" do
    it "respones to process!" do
      expect(event).to respond_to(:process!)
    end
  end
end
