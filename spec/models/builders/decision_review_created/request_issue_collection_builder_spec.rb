# frozen_string_literal: true

describe Builders::DecisionReviewCreated::RequestIssueCollectionBuilder do
  let(:event) { create(:decision_review_created_event, message_payload: decision_review_model.to_json) }
  let(:event_id) { event.id }
  let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }
  let(:decision_review_model) { build(:decision_review_created) }
  let(:decision_review_issues) { decision_review_model.decision_review_issues }
  let(:request_issues) { described_class.build(decision_review_model) }
  let(:builder) { described_class.new(decision_review_model) }
  let(:index) { decision_review_issues.index(issue) }
  let(:issue) { decision_review_issues.first }
  let(:claim_id) { decision_review_model.claim_id }

  before do
    decision_review_model.instance_variable_set(:@event_id, event_id)
  end

  describe "#self.build(decision_review_model)" do
    it "initializes an instance of Builders::DecisionReviewCreated::RequestIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(Builders::DecisionReviewCreated::RequestIssueCollectionBuilder)
    end

    it "returns an array of DecisionReviewCreated::RequestIssue(s) issue in the decision_review_issues array" do
      expect(request_issues.count).to eq(decision_review_issues.count)
      expect(request_issues).to all(be_an_instance_of(DecisionReviewCreated::RequestIssue))
    end
  end

  describe "#initialize(decision_review_model)" do
    it "initializes a new instance of Builders::DecisionReviewCreated::RequestIssueCollectionBuilder" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new instance variable @decision_review_model" do
      expect(builder.instance_variable_get(:@decision_review_model))
        .to be_an_instance_of(Transformers::DecisionReviewCreated)
    end

    it "initializes a new instance variable @bis_rating_profiles" do
      expect(builder.instance_variable_get(:@bis_rating_profiles))
        .to eq(nil)
    end

    context "when @decision_review_model.ep_code_category isn't 'rating' or doesn't contain rating issues" do
      context "@decision_review_model.ep_code_category is 'nonrating'" do
        it "does not initialize a new instance variable @earliest_issue_profile_date" do
          expect(builder.instance_variable_defined?(:@earliest_issue_profile_date)).to eq(false)
        end

        it "does not initialize a new instance variable @latest_issue_profile_date_plus_one_day" do
          expect(builder.instance_variable_defined?(:@latest_issue_profile_date_plus_one_day)).to eq(false)
        end

        it "leaves @bis_rating_profiles nil" do
          expect(builder.instance_variable_get(:@bis_rating_profiles)).to eq(nil)
        end
      end

      context "@decision_review_model doesn't contain rating issues" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }

        it "does not initialize a new instance variable @earliest_issue_profile_date" do
          expect(builder.instance_variable_defined?(:@earliest_issue_profile_date)).to eq(false)
        end

        it "does not initialize a new instance variable @latest_issue_profile_date_plus_one_day" do
          expect(builder.instance_variable_defined?(:@latest_issue_profile_date_plus_one_day)).to eq(false)
        end

        it "leaves @bis_rating_profiles nil" do
          expect(builder.instance_variable_get(:@bis_rating_profiles)).to eq(nil)
        end
      end
    end

    context "when @decision_review_model.ep_code_category equals 'rating' and contains rating issue(s)" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }

      it "initializes a new instance variable @earliest_issue_profile_date" do
        expect(builder.instance_variable_defined?(:@earliest_issue_profile_date)).to eq(true)
      end

      it "initializes a new instance variable @latest_issue_profile_date_plus_one_day" do
        expect(builder.instance_variable_defined?(:@latest_issue_profile_date_plus_one_day)).to eq(true)
      end

      context "when @earliest_issue_profile_date or @latest_issue_profile_date_plus_one_day return nil" do
        before do
          decision_review_issues.each do |issue|
            issue.prior_decision_rating_profile_date = nil
          end
        end

        it "does not overwrite instance variable @bis_rating_profiles with fetch_bis_rating_profiles response" do
          expect(builder.instance_variable_get(:@bis_rating_profiles)).to eq(nil)
        end
      end

      context "when @earliest_issue_profile_date and @latest_issue_profile_date_plus_one_day are not-nil" do
        it "overwrites instance variable @bis_rating_profiles with BIS response" do
          expect(builder.instance_variable_get(:@bis_rating_profiles)).not_to eq(nil)
        end
      end
    end
  end

  describe "#initialize_issue_profile_dates" do
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }

    it "initializes a new instance variable @earliest_issue_profile_date" do
      expect(builder.instance_variable_defined?(:@earliest_issue_profile_date)).to eq(true)
    end

    it "initializes a new instance variable @latest_issue_profile_date_plus_one_day" do
      expect(builder.instance_variable_defined?(:@latest_issue_profile_date_plus_one_day)).to eq(true)
    end
  end

  describe "#fetch_and_set_bis_rating_profiles" do
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }
    subject { builder.fetch_and_set_bis_rating_profiles }
    context "when @earliest_issue_profile_date or @latest_issue_profile_date_plus_one_day return nil" do
      before do
        decision_review_issues.each do |issue|
          issue.prior_decision_rating_profile_date = nil
        end
      end

      it "does not overwite instance variable @bis_rating_profiles with BIS response" do
        expect(builder.instance_variable_get(:@bis_rating_profiles)).to eq(nil)
      end
    end

    context "when @earliest_issue_profile_date and @latest_issue_profile_date_plus_one_day are not-nil" do
      it "overwrites instance variable @bis_rating_profiles with BIS response" do
        expect(builder.instance_variable_get(:@bis_rating_profiles)).not_to eq(nil)
      end
    end
  end

  describe "#build_issues" do
    subject { builder.build_issues }
    let(:decision_review_model) do
      build(:decision_review_created, :ineligible_nonrating_hlr_contested_with_additional_issue)
    end

    it "maps valid decision_review_issues into an array of DecisionReviewCreated::RequestIssue(s)" do
      expect(subject).to all(be_an_instance_of(DecisionReviewCreated::RequestIssue))
      expect(subject).to be_an_instance_of(Array)
    end
  end

  describe "#issues" do
    subject { builder.send(:issues) }

    let(:decision_review_model) do
      build(:decision_review_created, :ineligible_nonrating_hlr_contested_with_additional_issue)
    end

    it "returns an array of DecisionReviewIssue(s)" do
      expect(subject).to all(be_an_instance_of(DecisionReviewIssue))
      expect(subject.count).to eq(decision_review_issues.count)
    end
  end

  describe "#message_has_rating_issues?" do
    subject { builder.send(:message_has_rating_issues?) }
    context "when @decision_review_model.ep_code_category isn't 'rating' or doesn't contain rating issues" do
      context "@decision_review_model.ep_code_category is 'nonrating'" do
        it "returns false" do
          expect(subject).to eq(false)
        end
      end

      context "@decision_review_model doesn't contain rating issues" do
        it "returns false" do
          expect(subject).to eq(false)
        end
      end

      context "when @decision_review_model.ep_code_category equals 'rating' and contains rating issue(s)" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }

        it "returns true" do
          expect(subject).to eq(true)
        end
      end
    end
  end

  describe "#rating_ep_code_category?" do
    subject { builder.send(:rating_ep_code_category?) }
    context "when @decision_review_model.ep_code_category isn't 'rating'" do
      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when @decision_review_model.ep_code_category equals 'rating'" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end
  end

  describe "#at_least_one_valid_bis_issue?" do
    subject { builder.send(:at_least_one_valid_bis_issue?) }
    context "@decision_review_model has at least one issue containing prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

      it "returns true" do
        expect(subject).to eq(true)
      end
    end

    context "@decision_review_model has 0 issues containing prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }

      it "returns false" do
        expect(subject).to eq(false)
      end
    end
  end

  describe "#handle_no_issues_after_removing_contested" do
    subject { builder.send(:handle_no_issues_after_removing_contested) }
    let(:error) { AppealsConsumer::Error::RequestIssueCollectionBuildError }
    let(:error_msg) do
      "Failed building from #{described_class} for "\
      "DecisionReview Claim ID: #{claim_id} does not contain any valid issues after "\
      "removing 'CONTESTED' ineligible issues"
    end

    it "raises error AppealsConsumer::Error::RequestIssueCollectionBuildError with message" do
      expect { subject }.to raise_error(error, error_msg)
    end
  end

  describe "#build_request_issue(issue, index)" do
    subject { builder.send(:build_request_issue, issue, index) }

    context "when the DecisionReviewCreated::RequestIssue is built successfully" do
      it "returns a DecisionReviewCreated::RequestIssue instance for the issue passed in" do
        expect(subject).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
      end

      it "does not raise an exception" do
        expect { subject }.not_to raise_error
      end
    end

    context "when an exception is thrown while building the DecisionReviewCreated::RequestIssue" do
      let(:ri_collection_builder_error) { AppealsConsumer::Error::RequestIssueBuildError }

      context "when the issue has a NIL contention_id value" do
        before do
          issue.contention_id = nil
        end

        let(:ri_collection_builder_error_msg) do
          "Failed building from #{described_class} for "\
          "DecisionReview Claim ID: #{claim_id} Issue Index: #{index} - Issue is eligible but "\
          "has null for contention_id"
        end

        it "catches the error and raises AppealsConsumer::Error::RequestIssueBuildError with message using index as"\
          " the issue's identifier" do
          expect { subject }.to raise_error(ri_collection_builder_error, ri_collection_builder_error_msg)
        end
      end
    end
  end

  describe "issue_identifier_message(issue, index)" do
    subject { builder.send(:issue_identifier_message, issue, index) }

    context "when the issue has a not-nil contention_id value" do
      it "returns 'Issue Contention ID: issue.contention_id'" do
        expect(subject).to eq("Issue Contention ID: #{issue.contention_id}")
      end
    end

    context "when the issue has a nil contention_id value" do
      before do
        issue.contention_id = nil
      end

      it "returns 'Issue Index: decision_review_issues.index(issue)" do
        expect(subject).to eq("Issue Index: #{index}")
      end
    end
  end

  describe "#earliest_issue_profile_date" do
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }
    subject { builder.send(:earliest_issue_profile_date) }

    context "when valid_issue_profile_dates returns nil" do
      before do
        decision_review_issues.each do |issue|
          issue.prior_decision_rating_profile_date = nil
        end
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when valid_issue_profile_dates is not-nil" do
      it "returns the earliest decision_review_issue.prior_decision_rating_profile_date converted to Date" do
        expect(subject).to eq(decision_review_issues.first.prior_decision_rating_profile_date.to_date)
      end
    end
  end

  describe "#latest_issue_profile_date" do
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }
    subject { builder.send(:latest_issue_profile_date) }

    context "when valid_issue_profile_dates returns nil" do
      before do
        decision_review_issues.each do |issue|
          issue.prior_decision_rating_profile_date = nil
        end
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when valid_issue_profile_dates is not-nil" do
      it "returns the latest decision_review_issue.prior_decision_rating_profile_date converted to Date" do
        expect(subject).to eq(decision_review_issues.last.prior_decision_rating_profile_date.to_date)
      end
    end
  end

  describe "#latest_issue_profile_date_plus_one_day" do
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }
    subject { builder.send(:latest_issue_profile_date_plus_one_day) }

    context "when latest_issue_profile_date returns nil" do
      before do
        decision_review_issues.each do |issue|
          issue.prior_decision_rating_profile_date = nil
        end
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when latest_issue_profile_date does not return nil" do
      it "returns latest_issue_profile_date plus one day" do
        expect(subject).to eq(decision_review_issues.last.prior_decision_rating_profile_date.to_date + 1)
      end
    end
  end

  describe "valid_issue_profile_dates" do
    subject { builder.send(:valid_issue_profile_dates) }

    context "when valid_issues is not nil" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_with_two_issues) }
      context "when all valid_issues have nil for prior_decision_rating_profile_date" do
        before do
          decision_review_issues.each do |issue|
            issue.prior_decision_rating_profile_date = nil
          end
        end

        it "returns nil" do
          expect(subject).to eq nil
        end
      end

      context "when valid_issues has at least one not-nil value for prior_decision_rating_profile_date" do
        context "when there are nil values within profile_dates" do
          before do
            decision_review_issues.first.prior_decision_rating_profile_date = nil
          end

          it "removes the nil values" do
            expect(subject.any?(&:nil?)).to eq(false)
          end

          it "returns not-nil values in array" do
            expect(subject.class).to eq(Array)
          end

          it "returns array elements as Dates" do
            expect(subject.all? { |e| e.is_a?(Date) }).to eq(true)
          end
        end

        context "when there aren't any nil values within profile_dates" do
          it "returns not-nil values in array" do
            expect(subject.class).to eq(Array)
          end

          it "returns array elements as Dates" do
            expect(subject.all? { |e| e.is_a?(Date) }).to eq(true)
          end
        end
      end
    end
  end
end
