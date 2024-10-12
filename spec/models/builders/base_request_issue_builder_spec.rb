# frozen_string_literal: true

RSpec.describe Builders::BaseRequestIssueCollectionBuilder, type: :model do
  let(:fake_child_class) do
    Class.new(Builders::BaseRequestIssueBuilder)
      .new(issue, decision_review_model, bis_rating_profiles, request_issue)
  end
  let(:event) { create(:decision_review_created_event, message_payload: decision_review_model.to_json) }
  let(:event_id) { event.id }
  let(:decision_review_model) { build(:decision_review_created) }
  let(:issue) { decision_review_model.decision_review_issues_created.first }
  let(:bis_rating_profiles) { nil }
  let(:request_issue) { DecisionReviewCreated::RequestIssue.new }

  describe "#calculate_closed_at" do
    it "raises a NotImplementedError when it is NOT defined in an inherited class" do
      expect { fake_child_class.send(:calculate_closed_at) }
        .to raise_error(NotImplementedError, /must implement the #calculate_closed_at method/)
    end
  end

  describe "#calculate_rating_issue_associated_at" do
    it "raises a NotImplementedError when it is NOT defined in an inherited class" do
      expect { fake_child_class.send(:calculate_rating_issue_associated_at) }
        .to raise_error(NotImplementedError, /must implement the #calculate_rating_issue_associated_at method/)
    end
  end
end
