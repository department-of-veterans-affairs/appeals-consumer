# frozen_string_literal: true

describe Events::DecisionReviewUpdatedEvent, type: :model do
  let(:event){create(:decision_review_created_event)}

  describe "#process!" do
    it "respones to process!" do
      expect(event).to respond_to(:process!)
    end

  end
end