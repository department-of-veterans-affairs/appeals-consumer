# frozen_string_literal: true

RSpec.describe Builders::BaseRequestIssueCollectionBuilder, type: :model do
  let(:decision_review_model) { build(:decision_review_created) }
  let(:fake_child_class) { Class.new(Builders::BaseRequestIssueCollectionBuilder).new(decision_review_model) }

  describe "#_issues" do
    it "raises a NotImplementedError when it is NOT defined in an inherited class" do
      expect { fake_child_class.build_issues }
        .to raise_error(NotImplementedError, /must implement the #_issues method/)
    end
  end

  describe "#_build_request_issue" do
    it "raises a NotImplementedError when it is NOT defined in an inherited class" do
      expect do
        fake_child_class.send(:build_request_issue, decision_review_model.decision_review_issues_created.first, 0)
      end.to raise_error(NotImplementedError, /must implement the build_request_issue method/)
    end
  end
end
