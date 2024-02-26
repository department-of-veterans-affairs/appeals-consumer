# frozen_string_literal: true

describe Builders::RequestIssueBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:decision_review_issues) { decision_review_created.decision_review_issues }
  let(:issue) { decision_review_issues.first }
  let(:index) { decision_review_issues.index(issue) }
  let(:builder) { described_class.new(decision_review_created, issue, index) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }

    context "when there are multiple decision_review_issues and one contains 'CONTESTED' eligibility_result" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_contested_with_additional_issue) }

      it "a RequestIssueBuilder instance is only initialized for non-contested issues in array" do
        expect(described_class).to receive(:new).once.and_call_original
        subject
      end

      it "does not return the issue with 'CONTESTED' eligibility_result in the request issues array" do
        expect(subject.count).to eq(decision_review_issues.count - 1)
        expect(subject).to all(be_an_instance_of(RequestIssue))
      end
    end

    context "when there is one decision_review_issue and it has 'CONTESTED' eligibility_result" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_contested) }
      let(:error) { AppealsConsumer::Error::NoIssuesFound }
      let(:error_msg) do
        "DecisionReviewCreated Claim ID #{decision_review_created.claim_id} does not contain any valid issues"\
        " after removing 'CONTESTED' ineligible issues"
      end

      it "raises AppealsConsumer::Error::NoIssueFoundError with message" do
        expect { subject }.to raise_error(error, error_msg)
      end
    end
  end

  describe "#initialize(issue, deicision_review_created)" do
    let(:request_issue) { builder.request_issue }

    it "initializes a new RequestIssueBuilder instance for an individual DecisionReviewIssue" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new RequestIssue object for an individual DecisionReviewIssue" do
      expect(request_issue).to be_an_instance_of(RequestIssue)
    end

    it "assigns issue to the DecisionReviewIssue object passed in" do
      expect(builder.issue).to be_an_instance_of(DecisionReviewIssue)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:calculate_benefit_type)
      expect(builder).to receive(:calculate_contested_issue_description)
      expect(builder).to receive(:calculate_contention_reference_id)
      expect(builder).to receive(:assign_contested_rating_decision_reference_id)
      expect(builder).to receive(:calculate_contested_rating_issue_profile_date)
      expect(builder).to receive(:assign_contested_rating_issue_reference_id)
      expect(builder).to receive(:assign_contested_decision_issue_id)
      expect(builder).to receive(:calculate_decision_date)
      expect(builder).to receive(:calculate_ineligible_due_to_id)
      expect(builder).to receive(:calculate_ineligible_reason)
      expect(builder).to receive(:assign_is_unidentified)
      expect(builder).to receive(:calculate_unidentified_issue_text)
      expect(builder).to receive(:calculate_nonrating_issue_category)
      expect(builder).to receive(:calculate_nonrating_issue_description)
      expect(builder).to receive(:assign_untimely_exemption)
      expect(builder).to receive(:assign_untimely_exemption_notes)
      expect(builder).to receive(:assign_vacols_id)
      expect(builder).to receive(:assign_vacols_sequence_id)
      expect(builder).to receive(:calculate_closed_at)
      expect(builder).to receive(:calculate_closed_status)
      expect(builder).to receive(:calculate_contested_rating_issue_diagnostic_code)
      expect(builder).to receive(:calculate_ramp_claim_id)
      expect(builder).to receive(:calculate_rating_issue_associated_at)
      expect(builder).to receive(:assign_nonrating_issue_bgs_id)

      builder.assign_attributes
    end
  end

  describe "#calculate_benefit_type" do
    subject { builder.send(:calculate_benefit_type) }

    context "when decision_review_created.ep_code includes 'PMC'" do
      let(:decision_review_created) { build(:decision_review_created, :pension) }
      it "assigns the claim_review's benefit_type to 'pension'" do
        expect(subject).to eq(Builders::RequestIssueBuilder::PENSION_BENEFIT_TYPE)
      end
    end

    context "when decision_review_created.ep_code DOES NOT include 'PMC'" do
      it "assigns the claim_review's benefit_type to 'compensation'" do
        expect(subject).to eq(Builders::RequestIssueBuilder::COMPENSATION_BENEFIT_TYPE)
      end
    end
  end

  describe "#calculate_contested_issue_description" do
    subject { builder.send(:calculate_contested_issue_description) }

    context "when the issue is a rating or decision issue" do
      context "rating issue" do
        let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "rating decision" do
        let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "decision issue that has an associated rating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "decision issue that has an associated nonrating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end
    end

    context "when the issue is not a rating or decision issue" do
      context "nonrating and does not have an associated decision issue" do
        it "sets the Request Issue's contested_issue_description to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "unidentified" do
        let(:decision_review_created) { build(:decision_review_created, :unidentified) }
        it "sets the Request Issue's contested_issue_description to nil" do
          expect(subject).to eq(nil)
        end
      end
    end
  end

  describe "#calculate_contention_reference_id" do
    subject { builder.send(:calculate_contention_reference_id) }

    context "when the issue doesn't have a contention id" do
      context "eligible issue" do
        before do
          issue.contention_id = nil
        end

        let(:error) { AppealsConsumer::Error::NullContentionIdError }
        let(:error_msg) do
          "DecisionReviewCreated Claim ID #{decision_review_created.claim_id} - Issue index #{index} has a"\
          " null contention_id"
        end

        it "raises AppealsConsumer::Error::NullContentionIdError with message" do
          expect { subject }.to raise_error(error, error_msg)
        end
      end

      context "ineligible issue" do
        let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }

        it "assigns the Request Issue's contention_id to nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when the issue hasa contention id" do
      context "eligible issue" do
        it "assigns the Request Issue's contention_id to issue.contention_id" do
          expect(subject).to eq(issue.contention_id)
        end
      end

      context "ineligible issue" do
        let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }

        it "assigns the Request Issue's contention_id to nil" do
          expect(subject).to eq(nil)
        end
      end
    end
  end

  describe "#assign_contested_rating_decision_reference_id" do
    subject { builder.send(:assign_contested_rating_decision_reference_id) }

    context "when the issue has a prior_decision_rating_disability_sequence_number value" do
      let(:decision_review_created) { build(:decision_review_created, :rating_decision) }

      it "assigns the Request Issue's contested_rating_decision_reference_id to"\
         " issue.prior_decision_rating_disability_sequence_number" do
        expect(subject).to eq(issue.prior_decision_rating_disability_sequence_number)
      end
    end

    context "when the issue does not have a prior_decision_rating_disability_sequence_number value" do
      it "assigns the Request Issue's contested_rating_decision_reference_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_contested_rating_issue_profile_date" do
    subject { builder.send(:calculate_contested_rating_issue_profile_date) }

    context "when the issue is a rating issue" do
      before do
        issue.prior_decision_rating_profile_date = nil
      end
      let(:profile_date_converted_to_logical_type_int) { builder.send(:convert_profile_date_to_logical_type_int) }

      context "rating" do
        let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
        it "assigns the Request Issue's contested_rating_profile_date to issue.prior_decision_rating_profile_date"\
         " converted to logical type int" do
          expect(subject).to eq(profile_date_converted_to_logical_type_int)
        end
      end

      context "rating decision" do
        let(:decision_review_created) { build(:decision_review_created, :rating_decision) }

        it "assigns the Request Issue's contested_rating_profile_date to issue.prior_decision_rating_profile_date"\
         " converted to logical type int" do
          expect(subject).to eq(profile_date_converted_to_logical_type_int)
        end
      end

      context "decision issue with an associated rating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }

        it "assigns the Request Issue's contested_rating_profile_date to issue.prior_decision_rating_profile_date"\
         " converted to logical type int" do
          expect(subject).to eq(profile_date_converted_to_logical_type_int)
        end
      end
    end

    context "when the issue does not correspond to a rating issue" do
      context "nonrating" do
        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "unidentified" do
        let(:decision_review_created) { build(:decision_review_created, :unidentified) }

        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "decision issue corresponding to a nonrating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }

        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end
    end
  end

  describe "#assign_contested_rating_issue_reference_id" do
    subject { builder.send(:assign_contested_rating_issue_reference_id) }

    context "when the issue has a prior_rating_decision_id" do
      let(:decision_review_created) { build(:decision_review_created, :rating_issue) }

      it "assigns the Request Issue's contested_rating_issue_reference_id to issue.prior_rating_decision_id" do
        expect(subject).to eq(issue.prior_rating_decision_id)
      end
    end

    context "when the issue does not have a prior_rating_decision_id" do
      it "assigns the Request Issue's contested_rating_issue_reference_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#assign_contested_decision_issue_id" do
    subject { builder.send(:assign_contested_decision_issue_id) }

    context "when the issue has an associated_caseflow_decision_id" do
      let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }

      it "assigns the Request Issue's contested_decision_issue_id to issue.associated_caseflow_decision_id" do
        expect(subject).to eq(issue.associated_caseflow_decision_id)
      end
    end

    context "when the issue has an associated_caseflow_decision_id" do
      it "assigns the Request Issue's contested_decision_issue_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_decision_date" do
    subject { builder.send(:calculate_decision_date) }

    context "when issue does not have a prior_decision_notification_date" do
      context "when the issue is identified" do
        before do
          issue.prior_decision_notification_date = nil
        end

        let(:error) { AppealsConsumer::Error::NullPriorDecisionNotificationDate }
        let(:error_msg) do
          "DecisionReviewCreated Claim ID #{decision_review_created.claim_id} - Issue index #{index} has"\
            " a null prior_decision_notification_date"
        end

        it "raises AppealsConsumer::Error::NullPriorDecisionNotificationDate with message" do
          expect { subject }.to raise_error(error, error_msg)
        end
      end

      context "when the issue is unidentified" do
        before do
          decision_review_created.decision_review_issues.first.prior_decision_notification_date = nil
        end

        let(:decision_review_created) { build(:decision_review_created, :unidentified) }

        it "sets the Request Issue's decision_date to nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when issue has a prior_decision_notification_date" do
      context "when the issue is identified" do
        it "sets the Request Issue's decision_date to issue.prior_decision_notification_date" do
          expect(subject).to eq(issue.prior_decision_notification_date)
        end
      end

      context "when the issue is unidentified" do
        let(:decision_review_created) { build(:decision_review_created, :unidentified) }

        it "sets the Request Issue's decision_date to issue.prior_decision_notification_date" do
          expect(subject).to eq(issue.prior_decision_notification_date)
        end
      end
    end
  end

  describe "#calculate_ineligible_due_to_id" do
    subject { builder.send(:calculate_ineligible_due_to_id) }

    context "when the issue is ineligible" do
      context "due to a pending review" do
        let(:error) { AppealsConsumer::Error::NullAssociatedCaseflowRequestIssueId }
        let(:error_msg) do
          "DecisionReviewCreated Claim ID #{decision_review_created.claim_id} - Issue index #{index} has a"\
          " null associated_caseflow_request_issue_id"
        end

        context "when issue.eligibility_result is 'PENDING_HLR'" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "raises AppealsConsumer::Error::NullAssociatedCaseflowRequestIssueId with message" do
              expect { subject }.to raise_error(error, error_msg)
            end
          end
        end

        context "when issue.eligibility_result is 'PENDING_BOARD'" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_board) }

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "raises AppealsConsumer::Error::NullAssociatedCaseflowRequestIssueId with message" do
              expect { subject }.to raise_error(error, error_msg)
            end
          end
        end

        context "when issue.eligibility_result is 'PENDING_SUPPLEMENTAL'" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_supplemental) }

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "raises AppealsConsumer::Error::NullAssociatedCaseflowRequestIssueId with message" do
              expect { subject }.to raise_error(error, error_msg)
            end
          end
        end
      end

      context "due to any other reason" do
        let(:decision_review_created) { build(:decision_review_created, :ineligible_time_restriction_before_ama) }

        it "sets thr Request Issue's ineligible_due_to_id to nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when the issue is eligible" do
      it "sets the Request Issue's ineligible_due_to_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_ineligible_reason" do
    subject { builder.send(:calculate_ineligible_reason) }

    context "when the issue is eligible" do
      context "when the issue has 'ELIGIBLE' for eligibility_result" do
        it "sets the Request Issue's ineligible_reason to nil" do
          expect(subject).to eq nil
        end
      end

      context "when the issue has 'ELIGIBLE_LEGACY' for eligibility_result" do
        let(:decision_review_created) { build(:decision_review_created, :legacy_issue) }
        it "sets the Request Issue's ineligible_reason to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue is ineligible" do
      context "due to a pending decision review" do
        let(:duplicate_rating_issue) do
          described_class::INELIGIBLE_REASONS[:duplicate_of_rating_issue_in_active_review]
        end

        let(:duplicate_nonrating_issue) do
          described_class::INELIGIBLE_REASONS[:duplicate_of_nonrating_issue_in_active_review]
        end

        context "when the issue has 'PENDING_HLR' for eligibility_result" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }
          context "rating" do
            before do
              issue.prior_rating_decision_id = 13
              issue.prior_non_rating_decision_id = nil
            end

            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_BOARD' for eligibility_result" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_board) }
          context "rating" do
            before do
              issue.prior_rating_decision_id = 13
              issue.prior_non_rating_decision_id = nil
            end

            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_SUPPLEMENTAL' for eligibility_result" do
          let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_supplemental) }
          context "rating" do
            before do
              issue.prior_rating_decision_id = 13
              issue.prior_non_rating_decision_id = nil
            end

            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end
      end

      context "due to time restriction" do
        let(:ama_activation_date) { described_class::AMA_ACTIVATION_DATE }

        context "when the prior_decision_notification_date is before the ama activation date" do
          let(:before_ama) { described_class::INELIGIBLE_REASONS[:before_ama] }
          let(:decision_review_created) { build(:decision_review_created, :ineligible_time_restriction_before_ama) }

          it "sets the Request Issue's ineligible_reason to 'before_ama'" do
            expect(subject).to eq(before_ama)
          end
        end

        context "when the prior_decision_notification_date is on or after the ama activation date" do
          let(:untimely) { described_class::INELIGIBLE_REASONS[:untimely] }
          let(:decision_review_created) { build(:decision_review_created, :ineligible_time_restriction_untimely) }

          it "sets the Request Issue's ineligible_reason to 'untimely'" do
            expect(subject).to eq(untimely)
          end
        end
      end

      context "due to a pending legacy appeal" do
        let(:legacy_issue_not_withdrawn) do
          described_class::INELIGIBLE_REASONS[:legacy_issue_not_withdrawn]
        end
        let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_legacy_appeal) }

        it "sets the Request Issue's ineligible_reason to 'legacy_issue_not_withdrawn'" do
          expect(subject).to eq(legacy_issue_not_withdrawn)
        end
      end

      context "due to legacy time restriction" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_created) { build(:decision_review_created, :ineligible_legacy_time_restriction) }

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to no soc ssoc" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_created) { build(:decision_review_created, :ineligible_no_soc_ssoc) }

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to a completed board appeal" do
        let(:appeal_to_hlr) do
          described_class::INELIGIBLE_REASONS[:appeal_to_higher_level_review]
        end
        let(:decision_review_created) { build(:decision_review_created, :ineligible_completed_board) }

        it "sets the Request Issue's ineligible_reason to 'appeal_to_higher_level_review'" do
          expect(subject).to eq(appeal_to_hlr)
        end
      end

      context "due to a completed higher level review" do
        let(:hlr_to_hlr) do
          described_class::INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review]
        end
        let(:decision_review_created) { build(:decision_review_created, :ineligible_completed_hlr) }

        it "sets the Request Issue's ineligible_reason to 'higher_level_review_to_higher_level_review'" do
          expect(subject).to eq(hlr_to_hlr)
        end
      end
    end
  end

  describe "#assign_is_unidentified" do
    subject { builder.send(:assign_is_unidentified) }
    context "when the issue has unidentified as true" do
      let(:decision_review_created) { build(:decision_review_created, :unidentified) }

      it "sets the Request Issue's is_unidentified to true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has unidentified as false" do
      it "sets the Request Issue's is_unidentified to false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#calculate_unidentified_issue_text" do
    subject { builder.send(:calculate_unidentified_issue_text) }
    context "when the issue is unidentified" do
      let(:decision_review_created) { build(:decision_review_created, :unidentified) }

      it "sets the Request Issue's unidentified_issue_text to issue.prior_decision_text" do
        expect(subject).to eq(issue.prior_decision_text)
      end
    end

    context "when the issue is identified" do
      it "sets the Request Issue's unidentified_issue_text to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_nonrating_issue_category" do
    subject { builder.send(:calculate_nonrating_issue_category) }
    context "when the issue is nonrating" do
      context "nonrating" do
        it "sets the Request Issue's nonrating_issue_category to issue.prior_decision_type" do
          expect(subject).to eq(issue.prior_decision_type)
        end
      end

      context "decision issue associated with a nonrating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }
        it "sets the Request Issue's nonrating_issue_category to issue.prior_decision_type" do
          expect(subject).to eq(issue.prior_decision_type)
        end
      end
    end

    context "when the issue is NOT nonrating" do
      context "rating" do
        let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
        it "sets the Request Issue's nonrating_issue_category to nil" do
          expect(subject).to eq nil
        end
      end

      context "rating decision" do
        let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
        it "sets the Request Issue's nonrating_issue_category to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with a rating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
        it "sets the Request Issue's nonrating_issue_category to nil" do
          expect(subject).to eq nil
        end
      end

      context "unidentified" do
        let(:decision_review_created) { build(:decision_review_created, :unidentified) }
        it "sets the Request Issue's nonrating_issue_category to nil" do
          expect(subject).to eq nil
        end
      end
    end
  end

  describe "#calculate_nonrating_issue_description" do
    subject { builder.send(:calculate_nonrating_issue_description) }
    context "when issue is nonrating and doesn't have a value for associated_caseflow_decision_id" do
      let(:duplicate_text_removed_from_prior_decision_text) do
        "Service connection for tetnus denied"
      end

      it "sets the Request Issue's nonrating_issue_description to issue.prior_decision_text with"\
       " duplicate prior_decision_type text removed" do
        expect(subject).to eq(duplicate_text_removed_from_prior_decision_text)
      end
    end

    context "when the issue is nonrating and DOES have a value for associated_caseflow_decision_id" do
      let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }

      it "sets the Request Issue's nonrating_issue_description to nil" do
        expect(subject).to eq nil
      end
    end

    context "when the issue is NOT nonrating" do
      context "rating" do
        let(:decision_review_created) { build(:decision_review_created, :rating_issue) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "rating decision" do
        let(:decision_review_created) { build(:decision_review_created, :rating_decision) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with rating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "unidentified" do
        let(:decision_review_created) { build(:decision_review_created, :unidentified) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end
    end
  end

  describe "#assign_untimely_exemption" do
    subject { builder.send(:assign_untimely_exemption) }
    context "when the issue has nil for time_override" do
      it "sets the Request Issue's untimely_exemption to false" do
        expect(subject).to eq false
      end
    end

    context "when the issue has false for time_override" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_time_restriction_untimely) }
      it "sets the Request Issue's untimely_exemption to false" do
        expect(subject).to eq false
      end
    end

    context "when the issue has true for time_override" do
      let(:decision_review_created) { build(:decision_review_created, :eligible_time_override) }
      it "sets the Request Issue's untimely_exemption to true" do
        expect(subject).to eq true
      end
    end
  end

  describe "#untimely_exemption_notes" do
    subject { builder.send(:assign_untimely_exemption_notes) }
    context "when the issue has nil for time_override_reason" do
      it "sets the Request Issue's untimely_exemption to nil" do
        expect(subject).to eq nil
      end
    end

    context "when the issue has a value for time_override_reason" do
      let(:decision_review_created) { build(:decision_review_created, :eligible_time_override) }
      it "sets the Request Issue's untimely_exemption_notes to issue.time_override_reason" do
        expect(subject).to eq(issue.time_override_reason)
      end
    end
  end

  describe "#assign_vacols_id" do
    subject { builder.send(:assign_vacols_id) }
    context "when the issue has a value for legacy_appeal_id" do
      let(:decision_review_created) { build(:decision_review_created, :soc_opt_in) }
      it "sets the Request Issue's vacols_id to issue.legacy_appeal_id" do
        expect(subject).to eq(issue.legacy_appeal_id)
      end
    end

    context "when the issue does NOT have a value for legacy_appeal_id" do
      it "sets the Request Issue's vacols_id to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#assign_vacols_sequence_id" do
    subject { builder.send(:assign_vacols_sequence_id) }
    context "when the issue has a value for legacy_appeal_issue_id" do
      let(:decision_review_created) { build(:decision_review_created, :soc_opt_in) }
      it "sets the Request Issue's vacols_sequence_id to issue.legacy_appeal_id" do
        expect(subject).to eq(issue.legacy_appeal_issue_id)
      end
    end

    context "when the issue does NOT have a value for legacy_appeal_issue_id" do
      it "sets the Request Issue's vacols_sequence_id to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_closed_at" do
    subject { builder.send(:calculate_closed_at) }
    context "when issue is ineligible" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }
      it "sets the Request Issue's closed_at to decision_review_created.claim_creation_time" do
        expect(subject).to eq(decision_review_created.claim_creation_time)
      end
    end

    context "when issue is eligible" do
      it "sets the Request Issue's closed_at to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_closed_status" do
    subject { builder.send(:calculate_closed_status) }
    context "when issue is ineligible" do
      let(:decision_review_created) { build(:decision_review_created, :ineligible_pending_hlr) }
      let(:ineligible_closed_status) { described_class::INELIGIBLE_CLOSED_STATUS }
      it "sets the Request Issue's closed_status to 'ineligible'" do
        expect(subject).to eq(ineligible_closed_status)
      end
    end

    context "when issue is eligible" do
      it "sets the Request Issue's closed_status to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_contested_rating_issue_diagnostic_code" do
    subject { builder.send(:calculate_contested_rating_issue_diagnostic_code) }
    context "when the issue has a value for prior_rating_decision_id" do
      context "when the issue has a value for prior_decision_diagnostic_code" do
        context "rating" do
          let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
          it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
            expect(subject).to eq(issue.prior_decision_diagnostic_code)
          end
        end

        context "rating decision" do
          let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
          it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
            expect(subject).to eq(issue.prior_decision_diagnostic_code)
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
          it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
            expect(subject).to eq(issue.prior_decision_diagnostic_code)
          end
        end
      end

      context "when the issue does NOT have a value for prior_decision_diagnostic_code" do
        before do
          issue.prior_decision_diagnostic_code = nil
        end

        context "rating" do
          let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
          it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
            expect(subject).to eq nil
          end
        end

        context "rating decision" do
          let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
          it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
            expect(subject).to eq nil
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
          it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
            expect(subject).to eq nil
          end
        end
      end
    end

    context "when the issue is a nonrating issue" do
      context "nonrating" do
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with nonrating issue" do
        let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_non_rating_issue) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue is an unidentified issue" do
      let(:decision_review_created) { build(:decision_review_created, :unidentified) }
      it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_ramp_claim_id" do
    subject { builder.send(:calculate_ramp_claim_id) }
    context "when the issue has a value for prior_rating_decision_id" do
      context "and the issue has a value for prior_decision_ramp_id" do
        let(:decision_review_created) { build(:decision_review_created, :rating_with_ramp_id) }
        it "sets the Request Issue's ramp_claim_id to issue.prior_decision_ramp_id" do
          expect(subject).to eq(issue.prior_decision_ramp_id)
        end
      end

      context "and the issue does NOT have a value for prior_decision_ramp_id" do
        let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
        it "sets the Request Issue's ramp_claim_id to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue DOES NOT have a value for prior_rating_decision_id" do
      it "sets the Request Issue's ramp_claim_id to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_rating_issue_associated_at" do
    subject { builder.send(:calculate_rating_issue_associated_at) }

    context "when the issue does not have a value for prior_rating_decision_id" do
      context "nonrating" do
        it "sets the Request Issue's rating_issue_associated_at to nil" do
          expect(subject).to eq nil
        end
      end

      context "unidentified" do
        it "sets the Request Issue's rating_issue_associated_at to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associates with nonrating issue" do
        it "sets the Request Issue's rating_issue_associated_at to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue has a value for prior_rating_decision_id" do
      context "and the issue is eligible" do
        context "rating" do
          let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
          it "sets the Request Issue's rating_issue_associated_at to decision_review_created.claim_creation_time" do
            expect(subject).to eq(decision_review_created.claim_creation_time)
          end
        end

        context "rating decision" do
          let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
          it "sets the Request Issue's rating_issue_associated_at to decision_review_created.claim_creation_time" do
            expect(subject).to eq(decision_review_created.claim_creation_time)
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
          it "sets the Request Issue's rating_issue_associated_at to decision_review_created.claim_creation_time" do
            expect(subject).to eq(decision_review_created.claim_creation_time)
          end
        end
      end

      context "and the issue is ineligible" do
        before do
          issue.eligibility_result = "TIME_RESTRICTION"
        end

        context "rating" do
          let(:decision_review_created) { build(:decision_review_created, :rating_issue) }
          it "sets the Request Issue's rating_issue_associated_at to nil" do
            expect(subject).to eq(nil)
          end
        end

        context "rating decision" do
          let(:decision_review_created) { build(:decision_review_created, :rating_decision) }
          it "sets the Request Issue's rating_issue_associated_at to nil" do
            expect(subject).to eq(nil)
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_created) { build(:decision_review_created, :decision_issue_prior_rating_issue) }
          it "sets the Request Issue's rating_issue_associated_at to nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end
end
