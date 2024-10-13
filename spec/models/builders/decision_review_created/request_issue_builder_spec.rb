# frozen_string_literal: true

describe Builders::DecisionReviewCreated::RequestIssueBuilder do
  let(:event) { create(:decision_review_created_event, message_payload: decision_review_model.to_json) }
  let(:event_id) { event.id }
  let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }
  let(:decision_review_model) { build(:decision_review_created) }
  let(:issue) { decision_review_model.decision_review_issues_created.first }
  let(:builder) { described_class.new(issue, decision_review_model, bis_rating_profiles) }
  let(:bis_rating_profiles) { nil }
  let(:prior_decision_date_converted_to_logical_type) do
    builder.send(:prior_decision_date_converted_to_logical_type)
  end
  let(:claim_creation_time_converted_to_timestamp_ms) do
    builder.claim_creation_time_converted_to_timestamp_ms
  end

  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
    decision_review_model.instance_variable_set(:@event_id, event_id)
  end

  describe "#self.build(issue, decision_review_model)" do
    subject { described_class.build(issue, decision_review_model, bis_rating_profiles) }

    it "initializes a new RequestIssuesBuilder instance for an individual DecisionReviewIssue" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "defines all instance variables for the Request Issue" do
      expect(subject.instance_variable_defined?(:@contested_issue_description)).to be_truthy
      expect(subject.instance_variable_defined?(:@contention_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_decision_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_profile_date)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_reference_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_decision_issue_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@decision_date)).to be_truthy
      expect(subject.instance_variable_defined?(:@ineligible_due_to_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@is_unidentified)).to be_truthy
      expect(subject.instance_variable_defined?(:@unidentified_issue_text)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_category)).to be_truthy
      expect(subject.instance_variable_defined?(:@ineligible_reason)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_description)).to be_truthy
      expect(subject.instance_variable_defined?(:@untimely_exemption)).to be_truthy
      expect(subject.instance_variable_defined?(:@untimely_exemption_notes)).to be_truthy
      expect(subject.instance_variable_defined?(:@vacols_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@vacols_sequence_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@benefit_type)).to be_truthy
      expect(subject.instance_variable_defined?(:@closed_at)).to be_truthy
      expect(subject.instance_variable_defined?(:@closed_status)).to be_truthy
      expect(subject.instance_variable_defined?(:@contested_rating_issue_diagnostic_code)).to be_truthy
      expect(subject.instance_variable_defined?(:@ramp_claim_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@rating_issue_associated_at)).to be_truthy
      expect(subject.instance_variable_defined?(:@type)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_bgs_id)).to be_truthy
      expect(subject.instance_variable_defined?(:@nonrating_issue_bgs_source)).to be_truthy
    end

    it "returns the Request Issue" do
      expect(subject).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
    end
  end

  describe "#initialize(issue, decision_review_model)" do
    it "initializes a decision_review_model instance variable" do
      expect(builder.decision_review_model).to be_an_instance_of(Transformers::DecisionReviewCreated)
    end

    it "initializes an issue instance variable" do
      expect(builder.issue).to be_an_instance_of(DecisionReviewIssueCreated)
    end

    it "initializes a new Request Issue instance" do
      expect(builder.request_issue).to be_an_instance_of(DecisionReviewCreated::RequestIssue)
    end

    it "initializes an instance variable @bis_rating_profile" do
      expect(builder.instance_variable_defined?(:@bis_rating_profiles)).to eq(true)
    end
  end

  describe "#assign_attributes" do
    it "calls assign and calculate methods" do
      expect(builder).to receive(:assign_methods)
      expect(builder).to receive(:calculate_methods)

      builder.assign_attributes
    end
  end

  describe "#assign_methods" do
    it "calls assign methods" do
      expect(builder).to receive(:assign_contested_rating_decision_reference_id)
      expect(builder).to receive(:assign_contested_rating_issue_reference_id)
      expect(builder).to receive(:assign_contested_decision_issue_id)
      expect(builder).to receive(:assign_untimely_exemption)
      expect(builder).to receive(:assign_untimely_exemption_notes)
      expect(builder).to receive(:assign_vacols_id)
      expect(builder).to receive(:assign_vacols_sequence_id)
      expect(builder).to receive(:assign_nonrating_issue_bgs_id)
      expect(builder).to receive(:assign_type)

      builder.send(:assign_methods)
    end
  end

  describe "#calculate_methods" do
    it "calls calculate methods" do
      expect(builder).to receive(:calculate_contention_reference_id)
      expect(builder).to receive(:calculate_benefit_type)
      expect(builder).to receive(:calculate_contested_issue_description)
      expect(builder).to receive(:calculate_contested_rating_issue_profile_date)
      expect(builder).to receive(:calculate_decision_date)
      expect(builder).to receive(:calculate_ineligible_due_to_id)
      expect(builder).to receive(:calculate_ineligible_reason)
      expect(builder).to receive(:calculate_unidentified_issue_text)
      expect(builder).to receive(:calculate_nonrating_issue_category)
      expect(builder).to receive(:calculate_nonrating_issue_description)
      expect(builder).to receive(:calculate_closed_at)
      expect(builder).to receive(:calculate_closed_status)
      expect(builder).to receive(:calculate_contested_rating_issue_diagnostic_code)
      expect(builder).to receive(:calculate_ramp_claim_id)
      expect(builder).to receive(:calculate_rating_issue_associated_at)
      expect(builder).to receive(:calculate_is_unidentified)
      expect(builder).to receive(:calculate_nonrating_issue_bgs_source)

      builder.send(:calculate_methods)
    end
  end

  describe "#calculate_nonrating_issue_bgs_source" do
    subject { builder.send(:calculate_nonrating_issue_bgs_source) }

    context "when the issue has a prior_decision_rating_sn value" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_with_decision_source) }

      it "assigns the Request Issue's nonrating_issue_bgs_source to"\
         " issue.prior_decision_source converted to a string" do
        expect(subject).to eq(issue.prior_decision_source.to_s)
      end
    end

    context "when the issue does not have a prior_decision_source value" do
      it "assigns the Request Issue's nonrating_issue_bgs_source to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_benefit_type" do
    subject { builder.send(:calculate_benefit_type) }

    context "when decision_review_model.ep_code includes 'PMC'" do
      let(:decision_review_model) { build(:decision_review_created, :nonrating_hlr_pension) }
      it "assigns the claim_review's benefit_type to 'pension'" do
        expect(subject).to eq(described_class::PENSION_BENEFIT_TYPE)
      end
    end

    context "when decision_review_model.ep_code DOES NOT include 'PMC'" do
      it "assigns the claim_review's benefit_type to 'compensation'" do
        expect(subject).to eq(described_class::COMPENSATION_BENEFIT_TYPE)
      end
    end
  end

  describe "#calculate_contested_issue_description" do
    subject { builder.send(:calculate_contested_issue_description) }

    context "when the issue is a rating or decision issue" do
      context "rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "rating decision" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "decision issue that has an associated rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }
        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "decision issue that has an associated nonrating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }
        let(:duplicate_text_removed_from_prior_decision_text) do
          "Service connection for tetnus denied"
        end

        it "sets the Request Issue's contested_issue_description to issue.prior_decision_text" do
          expect(subject).to eq(duplicate_text_removed_from_prior_decision_text)
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
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }
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
          "Issue is eligible but has null for contention_id"
        end

        it "raises AppealsConsumer::Error::NullContentionIdError with message" do
          expect { subject }.to raise_error(error, error_msg)
        end
      end

      context "ineligible issue" do
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }

        it "assigns the Request Issue's contention_id to nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when the issue has a contention id" do
      context "eligible issue" do
        it "assigns the Request Issue's contention_id to issue.contention_id" do
          expect(subject).to eq(issue.contention_id)
        end
      end

      context "ineligible issue" do
        before do
          issue.contention_id = 123_456_789
        end

        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }

        it "assigns the Request Issue's contention_id to issue.contention_id" do
          expect(subject).to eq(issue.contention_id)
        end
      end
    end
  end

  describe "#assign_contested_rating_decision_reference_id" do
    subject { builder.send(:assign_contested_rating_decision_reference_id) }

    context "when the issue has a prior_decision_rating_sn value" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }

      it "assigns the Request Issue's contested_rating_decision_reference_id to"\
         " issue.prior_decision_rating_sn converted to a string" do
        expect(subject).to eq(issue.prior_decision_rating_sn.to_s)
      end
    end

    context "when the issue does not have a prior_decision_rating_sn value" do
      it "assigns the Request Issue's contested_rating_decision_reference_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_contested_rating_issue_profile_date" do
    subject { builder.send(:calculate_contested_rating_issue_profile_date) }

    context "when the issue is a rating issue" do
      context "rating" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
        it "assigns the Request Issue's contested_rating_profile_date to issue.prior_decision_rating_profile_date" do
          expect(subject).to eq(issue.prior_decision_rating_profile_date)
        end
      end

      context "decision issue with an associated rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }

        it "assigns the Request Issue's contested_rating_profile_date to issue.prior_decision_rating_profile_date" do
          expect(subject).to eq(issue.prior_decision_rating_profile_date)
        end
      end
    end

    context "when the issue does not correspond to a rating issue" do
      context "rating decision" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }

        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "nonrating" do
        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }

        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end

      context "decision issue corresponding to a nonrating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }

        it "assigns the Request Issue's contested_rating_profile_date to nil" do
          expect(subject).to eq(nil)
        end
      end
    end
  end

  describe "#assign_contested_rating_issue_reference_id" do
    subject { builder.send(:assign_contested_rating_issue_reference_id) }

    context "when the issue has a prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

      it "assigns the Request Issue's contested_rating_issue_reference_id to issue.prior_rating_decision_id converted"\
       " to a string" do
        expect(subject).to eq(issue.prior_rating_decision_id.to_s)
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

    context "when the issue has an prior_caseflow_decision_issue_id" do
      let(:decision_review_model) do
        build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr)
      end

      it "assigns the Request Issue's contested_decision_issue_id to issue.prior_caseflow_decision_issue_id" do
        expect(subject).to eq(issue.prior_caseflow_decision_issue_id)
      end
    end

    context "when the issue has an prior_caseflow_decision_issue_id" do
      it "assigns the Request Issue's contested_decision_issue_id to nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#calculate_decision_date" do
    subject { builder.send(:calculate_decision_date) }

    context "when issue does not have a prior_decision_date" do
      context "when the issue is identified" do
        let(:error) { AppealsConsumer::Error::NullPriorDecisionDate }
        let(:error_msg) do
          "#{error}-Issue with contention_id #{issue.contention_id} is identified but has null for prior_decision_date"
        end

        before do
          issue.prior_decision_date = nil
          allow(Rails.logger).to receive(:error)
        end

        it "logs message as error" do
          expect(Rails.logger).to receive(:error).with(/#{error_msg}/)
          subject
        end

        it "sets decision_date to nil" do
          expect(subject).to eq nil
        end

        context "when there is already a message in the event_audit's notes column" do
          let!(:event_audit_with_note) do
            create(:event_audit, event: event, status: :in_progress, notes: "Note #{Time.zone.now}: Test note")
          end

          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_with_note.reload.notes)
              .to eq("Note #{Time.zone.now}: Test note - Note #{Time.zone.now}: #{error_msg}")
          end
        end

        context "when there isn't a message in the event_audit's notes column" do
          let!(:event_audit_without_note) { create(:event_audit, event: event, status: :in_progress) }
          it "updates the event's last event_audit record that has status: 'IN_PROGRESS' with the msg" do
            subject
            expect(event_audit_without_note.reload.notes).to eq("Note #{Time.zone.now}: #{error_msg}")
          end
        end
      end

      context "when the issue is unidentified" do
        before do
          issue.prior_decision_date = nil
        end

        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }

        it "sets the Request Issue's decision_date to nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when issue has a prior_decision_date" do
      context "when the issue is identified" do
        it "sets the Request Issue's decision_date to issue.prior_decision_date converted to logical" do
          expect(subject).to eq(prior_decision_date_converted_to_logical_type)
        end
      end

      context "when the issue is unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }

        it "sets the Request Issue's decision_date to issue.prior_decision_date converted to logical" do
          expect(subject).to eq(prior_decision_date_converted_to_logical_type)
        end
      end
    end
  end

  describe "#calculate_ineligible_due_to_id" do
    before do
      issue.contention_id = 1
    end
    subject { builder.send(:calculate_ineligible_due_to_id) }

    context "when the issue is ineligible" do
      context "due to a pending review" do
        let(:logged_message) do
          "[Builders::DecisionReviewCreated::RequestIssueBuilder] Issue with contention id of 1 is "\
          "ineligible due to a pending review but has null for associated_caseflow_request_issue_id"
        end
        let(:note) do
          "Issue with contention id of 1 is ineligible due to a pending review but has null"\
          " for associated_caseflow_request_issue_id"
        end
        context "when issue.eligibility_result is 'PENDING_HLR'" do
          let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "logs 'Issue is ineligible due to a pending review "\
            "but has null for associated_caseflow_request_issue_id'" do
              expect(Rails.logger).to receive(:info).with(logged_message)

              subject
            end

            it "updates the 'notes' column on the event_audit with the logged message" do
              subject
              expect(EventAudit.last.notes).to include(note)
            end
          end
        end

        context "when issue.eligibility_result is 'PENDING_BOARD_APPEAL'" do
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_pending_board_appeal)
          end

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "logs 'Issue is ineligible due to a pending review "\
            "but has null for associated_caseflow_request_issue_id'" do
              expect(Rails.logger).to receive(:info).with(logged_message)

              subject
            end

            it "updates the 'notes' column on the event_audit with the logged message" do
              subject
              expect(EventAudit.last.notes).to include(note)
            end
          end
        end

        context "when issue.eligibility_result is 'PENDING_SUPPLEMENTAL'" do
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_pending_supplemental)
          end

          context "when issue.associated_caseflow_request_issue_id is present" do
            it "sets the Request Issue's ineligible_due_to_id to issue.associated_caseflow_request_issue_id" do
              expect(subject).to eq(issue.associated_caseflow_request_issue_id)
            end
          end

          context "when issue.associated_caseflow_request_issue_id is not present" do
            before do
              issue.associated_caseflow_request_issue_id = nil
            end

            it "logs 'Issue is ineligible due to a pending review "\
            "but has null for associated_caseflow_request_issue_id'" do
              expect(Rails.logger).to receive(:info).with(logged_message)

              subject
            end

            it "updates the 'notes' column on the event_audit with the logged message" do
              subject
              expect(EventAudit.last.notes).to include(note)
            end
          end
        end
      end

      context "due to any other reason" do
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
        end

        it "sets the Request Issue's ineligible_due_to_id to nil" do
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
        let(:decision_review_model) do
          build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr_legacy)
        end
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
          context "rating" do
            let(:decision_review_model) { build(:decision_review_created, :ineligible_rating_hlr_pending_hlr) }
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_BOARD_APPEAL' for eligibility_result" do
          context "rating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_rating_hlr_pending_board_appeal)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_nonrating_hlr_pending_board_appeal)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_SUPPLEMENTAL' for eligibility_result" do
          context "rating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_rating_hlr_pending_supplemental)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_nonrating_hlr_pending_supplemental)
            end

            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end
      end

      context "due to time restriction" do
        let(:ama_activation_date) { described_class::AMA_ACTIVATION_DATE }

        context "when the prior_decision_date is before the ama activation date" do
          let(:before_ama) { described_class::INELIGIBLE_REASONS[:before_ama] }
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
          end

          it "sets the Request Issue's ineligible_reason to 'before_ama'" do
            expect(subject).to eq(before_ama)
          end
        end

        context "when the prior_decision_date is on or after the ama activation date" do
          let(:untimely) { described_class::INELIGIBLE_REASONS[:untimely] }
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_untimely)
          end

          it "sets the Request Issue's ineligible_reason to 'untimely'" do
            expect(subject).to eq(untimely)
          end
        end
      end

      context "due to a pending legacy appeal" do
        let(:legacy_issue_not_withdrawn) do
          described_class::INELIGIBLE_REASONS[:legacy_issue_not_withdrawn]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_pending_legacy_appeal)
        end

        it "sets the Request Issue's ineligible_reason to 'legacy_issue_not_withdrawn'" do
          expect(subject).to eq(legacy_issue_not_withdrawn)
        end
      end

      context "due to legacy time restriction" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_legacy_time_restriction)
        end

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to no soc ssoc" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_no_soc_ssoc) }

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to a completed board appeal" do
        let(:appeal_to_hlr) do
          described_class::INELIGIBLE_REASONS[:appeal_to_higher_level_review]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_completed_board_appeal)
        end

        it "sets the Request Issue's ineligible_reason to 'appeal_to_higher_level_review'" do
          expect(subject).to eq(appeal_to_hlr)
        end
      end

      context "due to a completed higher level review" do
        let(:hlr_to_hlr) do
          described_class::INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review]
        end
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_completed_hlr) }

        it "sets the Request Issue's ineligible_reason to 'higher_level_review_to_higher_level_review'" do
          expect(subject).to eq(hlr_to_hlr)
        end
      end

      context "due to being contested" do
        let(:contested) do
          described_class::INELIGIBLE_REASONS[:contested]
        end
        let(:decision_review_model) { build(:decision_review_created, :ineligible_contested) }

        it "sets the Request Issue's ineligible_reason to 'contested'" do
          expect(subject).to eq(contested)
        end
      end
    end

    context "when issue has an unrecognized eligibility_result" do
      before do
        issue.eligibility_result = "UNKNOWN"
      end

      let(:error) { AppealsConsumer::Error::IssueEligibilityResultNotRecognized }
      let(:error_msg) do
        "Issue has an unrecognized eligibility_result: #{issue.eligibility_result}"
      end

      it "raises AppealsConsumer::Error::IssueEligibilityResultNotRecognized with message" do
        expect { subject }.to raise_error(error, error_msg)
      end
    end
  end

  describe "#calculate_is_unidentified" do
    subject { builder.send(:calculate_is_unidentified) }

    context "decision_review_model has 'NON-RATING' for ep_code_category" do
      context "issue has true for unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_unidentified) }

        it "sets is_unidentified to false" do
          expect(subject).to eq false
        end
      end

      context "issue has false for unidentified" do
        it "sets is_unidentified to false" do
          expect(subject).to eq false
        end
      end
    end

    context "decision_review_model does not have 'NON-RATING' for ep_code_category" do
      context "issue has true for unidentified" do
        let(:decision_review_model) do
          build(:decision_review_created, :eligible_rating_hlr_unidentified_veteran_claimant)
        end

        it "sets is_unidentified to true" do
          expect(subject).to eq true
        end
      end

      context "issue has false for unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_veteran_claimant) }

        it "sets is_unidentified to false" do
          expect(subject).to eq false
        end
      end
    end
  end

  describe "#calculate_unidentified_issue_text" do
    subject { builder.send(:calculate_unidentified_issue_text) }
    context "decision_review_model has 'NON-RATING' for ep_code_category" do
      context "issue has true for unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_unidentified) }

        it "sets unidentified_issue_text to nil" do
          expect(subject).to eq nil
        end
      end

      context "issue has false for unidentified" do
        it "sets unidentified_issue_text to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "decision_review_model does not have 'NON-RATING' for ep_code_category" do
      context "issue has true for unidentified" do
        let(:decision_review_model) do
          build(:decision_review_created, :eligible_rating_hlr_unidentified_veteran_claimant)
        end

        it "sets unidentified_issue_text to the issue's prior_decision_text" do
          expect(subject).to eq(issue.prior_decision_text)
        end
      end

      context "issue has false for unidentified" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_veteran_claimant) }

        it "sets unidentified_issue_text to nil" do
          expect(subject).to eq nil
        end
      end
    end
  end

  describe "#assign_nonrating_issue_bgs_id" do
    subject { builder.send(:assign_nonrating_issue_bgs_id) }
    context "when the issue has a prior_non_rating_decision_id present" do
      it "sets the Request Issue's nonrating_issue_bgs_id to issue.prior_non_rating_decision_id converted"\
       " to a string" do
        expect(subject).to eq(issue.prior_non_rating_decision_id.to_s)
      end
    end

    context "when the issue does not have a prior_non_rating_decision_id present" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      it "sets the Request Issue's nonrating_issue_bgs_id to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_nonrating_issue_category" do
    subject { builder.send(:calculate_nonrating_issue_category) }
    context "decision_review_model has 'NON-RATING' for ep_code_category" do
      it "sets nonrating_issue_category to issue's prior_decision_type" do
        expect(subject).to eq(issue.prior_decision_type)
      end
    end

    context "decision_review_model does not have 'NON-RATING' for ep_code_category" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_veteran_claimant) }

      it "sets nonrating_issue_category to nil" do
        expect(subject).to eq nil
      end
    end
  end

  describe "#calculate_nonrating_issue_description" do
    subject { builder.send(:calculate_nonrating_issue_description) }
    context "decision_review_model has 'NON-RATING' for ep_code_category" do
      context "issue doesn't have a value for prior_caseflow_decision_issue_id" do
        let(:duplicate_text_removed_from_prior_decision_text) do
          "Service connection for tetnus denied"
        end

        it "sets the Request Issue's nonrating_issue_description to issue.prior_decision_text with"\
          " duplicate prior_decision_type text removed" do
          expect(subject).to eq(duplicate_text_removed_from_prior_decision_text)
        end
      end

      context "issue does have a value for prior_caseflow_decision_issue_id" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "decision_review_model does not have 'NON-RATING' for ep_code_category" do
      context "rating" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_veteran_claimant) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "rating decision" do
        let(:decision_review_model) do
          build(:decision_review_created, :eligible_rating_decision_hlr_veteran_claimant)
        end

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }

        it "sets the Request Issue's nonrating_issue_description to nil" do
          expect(subject).to eq nil
        end
      end

      context "rating unidentified" do
        let(:decision_review_model) do
          build(:decision_review_created, :eligible_rating_hlr_unidentified_veteran_claimant)
        end

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
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_untimely)
      end
      it "sets the Request Issue's untimely_exemption to false" do
        expect(subject).to eq false
      end
    end

    context "when the issue has true for time_override" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_time_override) }
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
      let(:decision_review_model) { build(:decision_review_created, :eligible_nonrating_hlr_time_override) }
      it "sets the Request Issue's untimely_exemption_notes to issue.time_override_reason" do
        expect(subject).to eq(issue.time_override_reason)
      end
    end
  end

  describe "#assign_vacols_id" do
    subject { builder.send(:assign_vacols_id) }
    context "when the issue has a value for legacy_appeal_id" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_rating_decision_hlr_pending_legacy_appeal)
      end
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
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_rating_decision_hlr_pending_legacy_appeal)
      end
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
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      it "sets the Request Issue's closed_at to claim_creation_time_converted_to_timestamp_ms" do
        expect(subject).to eq(claim_creation_time_converted_to_timestamp_ms)
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
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      let(:ineligible_closed_status) { described_class::CLOSED_STATUSES[:ineligible_closed_status] }
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
    context "when the issue has a value for prior_decision_diagnostic_code" do
      context "rating" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
        it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
          expect(subject).to eq(issue.prior_decision_diagnostic_code)
        end
      end

      context "decision issue associated with a rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }
        it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
          expect(subject).to eq(issue.prior_decision_diagnostic_code)
        end
      end

      context "rating decision" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
        it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
          expect(subject).to eq(issue.prior_decision_diagnostic_code)
        end
      end

      context "nonrating" do
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with nonrating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "when the issue is an unidentified issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue does NOT have a value for prior_decision_diagnostic_code" do
      before do
        issue.prior_decision_diagnostic_code = nil
      end

      context "rating" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with a rating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "nonrating" do
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "decision issue associated with nonrating issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "when the issue is an unidentified issue" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }
        it "sets the Request Issue's contested_rating_issue_diagnostic_code to nil" do
          expect(subject).to eq nil
        end
      end

      context "when the issue is a rating decision" do
        before do
          issue.prior_decision_diagnostic_code = "5008"
        end

        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
        it "sets Request Issue's contested_rating_issue_diagnostic_code to issue.prior_decision_diagnostic_code" do
          expect(subject).to eq(issue.prior_decision_diagnostic_code)
        end
      end
    end
  end

  describe "#calculate_ramp_claim_id" do
    subject { builder.send(:calculate_ramp_claim_id) }
    context "when the issue has a not-null prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      let(:bis_rating_profiles) do
        {
          rba_issue_list: {
            rba_issue: {
              rba_issue_id: "1234",
              prfil_date: Date.new(1970, 1, 1)
            }
          },
          rba_claim_list: {
            rba_claim: [
              {
                bnft_clm_tc: "682HLRRRAMP",
                clm_id: "1002003",
                prfl_date: issue.prior_decision_rating_profile_date
              },
              {
                bnft_clm_tc: "030HLRR",
                clm_id: "1002005",
                prfl_date: Date.new(1970, 1, 1)
              }
            ]
          }
        }
      end

      it "returns the claim id of the RAMP ep if there is one" do
        expect(subject).to eq("1002003")
      end
    end

    context "when the issue has a null prior_rating_decision_id" do
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

      context "rating decision" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
        it "sets the Request Issue's rating_issue_associated_at to nil" do
          expect(subject).to eq nil
        end
      end
    end

    context "when the issue has a value for prior_rating_decision_id" do
      context "and the issue is eligible" do
        context "rating" do
          let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
          it "sets the Request Issue's rating_issue_associated_at to claim_creation_time_converted_to_timestamp_ms" do
            expect(subject).to eq(claim_creation_time_converted_to_timestamp_ms)
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }
          it "sets the Request Issue's rating_issue_associated_at to claim_creation_time_converted_to_timestamp_ms" do
            expect(subject).to eq(claim_creation_time_converted_to_timestamp_ms)
          end
        end
      end

      context "and the issue is ineligible" do
        before do
          issue.eligibility_result = "TIME_RESTRICTION"
        end

        context "rating" do
          let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
          it "sets the Request Issue's rating_issue_associated_at to nil" do
            expect(subject).to eq(nil)
          end
        end

        context "decision issue associated with a rating issue" do
          let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_rating_hlr) }
          it "sets the Request Issue's rating_issue_associated_at to nil" do
            expect(subject).to eq(nil)
          end
        end
      end
    end
  end

  describe "#assign_type" do
    subject { builder.send(:assign_type) }
    it "sets the Request Issue's type to 'DecisionReviewCreated::RequestIssue'" do
      expect(subject).to eq(described_class::REQUEST_ISSUE)
    end
  end

  describe "#determine_ineligible_reason" do
    subject { builder.send(:determine_ineligible_reason) }

    context "when the issue is eligible" do
      context "when the issue has 'ELIGIBLE' for eligibility_result" do
        it "sets the Request Issue's ineligible_reason to nil" do
          expect(subject).to eq nil
        end
      end

      context "when the issue has 'ELIGIBLE_LEGACY' for eligibility_result" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_legacy) }
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
          context "rating" do
            let(:decision_review_model) { build(:decision_review_created, :ineligible_rating_hlr_pending_hlr) }
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_BOARD_APPEAL' for eligibility_result" do
          context "rating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_rating_hlr_pending_board_appeal)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_nonrating_hlr_pending_board_appeal)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end

        context "when the issue has 'PENDING_SUPPLEMENTAL' for eligibility_result" do
          context "rating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_rating_hlr_pending_supplemental)
            end
            it "sets the Request Issue's ineligible_reason to 'duplicate_of_rating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_rating_issue)
            end
          end

          context "nonrating" do
            let(:decision_review_model) do
              build(:decision_review_created, :ineligible_nonrating_hlr_pending_supplemental)
            end

            it "sets the Request Issue's ineligible_reason to 'duplicate_of_nonrating_issue_in_active_review'" do
              expect(subject).to eq(duplicate_nonrating_issue)
            end
          end
        end
      end

      context "due to time restriction" do
        let(:ama_activation_date) { described_class::AMA_ACTIVATION_DATE }

        context "when the prior_decision_date is before the ama activation date" do
          let(:before_ama) { described_class::INELIGIBLE_REASONS[:before_ama] }
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
          end

          it "sets the Request Issue's ineligible_reason to 'before_ama'" do
            expect(subject).to eq(before_ama)
          end
        end

        context "when the prior_decision_date is on or after the ama activation date" do
          let(:untimely) { described_class::INELIGIBLE_REASONS[:untimely] }
          let(:decision_review_model) do
            build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_untimely)
          end

          it "sets the Request Issue's ineligible_reason to 'untimely'" do
            expect(subject).to eq(untimely)
          end
        end
      end

      context "due to a pending legacy appeal" do
        let(:legacy_issue_not_withdrawn) do
          described_class::INELIGIBLE_REASONS[:legacy_issue_not_withdrawn]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_pending_legacy_appeal)
        end
        it "sets the Request Issue's ineligible_reason to 'legacy_issue_not_withdrawn'" do
          expect(subject).to eq(legacy_issue_not_withdrawn)
        end
      end

      context "due to legacy time restriction" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_legacy_time_restriction)
        end

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to no soc ssoc" do
        let(:legacy_appeal_not_eligible) do
          described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible]
        end
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_no_soc_ssoc) }

        it "sets the Request Issue's ineligible_reason to 'legacy_appeal_not_eligible'" do
          expect(subject).to eq(legacy_appeal_not_eligible)
        end
      end

      context "due to a completed board appeal" do
        let(:appeal_to_hlr) do
          described_class::INELIGIBLE_REASONS[:appeal_to_higher_level_review]
        end
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_completed_board_appeal)
        end

        it "sets the Request Issue's ineligible_reason to 'appeal_to_higher_level_review'" do
          expect(subject).to eq(appeal_to_hlr)
        end
      end

      context "due to a completed higher level review" do
        let(:hlr_to_hlr) do
          described_class::INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review]
        end
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_completed_hlr) }

        it "sets the Request Issue's ineligible_reason to 'higher_level_review_to_higher_level_review'" do
          expect(subject).to eq(hlr_to_hlr)
        end
      end
    end

    context "when issue has an unrecognized eligibility_result" do
      before do
        issue.eligibility_result = "UNKNOWN"
      end

      let(:error) { AppealsConsumer::Error::IssueEligibilityResultNotRecognized }
      let(:error_msg) do
        "Issue has an unrecognized eligibility_result: #{issue.eligibility_result}"
      end

      it "raises AppealsConsumer::Error::IssueEligibilityResultNotRecognized with message" do
        expect { subject }.to raise_error(error, error_msg)
      end
    end
  end

  describe "#duplicate_of_nonrating_issue_in_active_review" do
    subject { builder.send(:duplicate_of_nonrating_issue_in_active_review) }
    let(:duplicate_nonrating_issue) do
      described_class::INELIGIBLE_REASONS[:duplicate_of_nonrating_issue_in_active_review]
    end

    it "returns 'duplicate_of_nonrating_issue_in_active_review'" do
      expect(subject).to eq(duplicate_nonrating_issue)
    end
  end

  describe "#duplicate_of_rating_issue_in_active_review" do
    subject { builder.send(:duplicate_of_rating_issue_in_active_review) }
    let(:duplicate_nonrating_issue) do
      described_class::INELIGIBLE_REASONS[:duplicate_of_rating_issue_in_active_review]
    end

    it "returns 'duplicate_of_rating_issue_in_active_review'" do
      expect(subject).to eq(duplicate_nonrating_issue)
    end
  end

  describe "#untimely" do
    subject { builder.send(:untimely) }
    let(:untimely) { described_class::INELIGIBLE_REASONS[:untimely] }

    it "returns 'untimely'" do
      expect(subject).to eq(untimely)
    end
  end

  describe "#higher_level_review_to_higher_level_review" do
    subject { builder.send(:higher_level_review_to_higher_level_review) }
    let(:higher_level_review_to_higher_level_review) do
      described_class::INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review]
    end

    it "returns 'higher_level_review_to_higher_level_review'" do
      expect(subject).to eq(higher_level_review_to_higher_level_review)
    end
  end

  describe "#appeal_to_higher_level_review" do
    subject { builder.send(:appeal_to_higher_level_review) }
    let(:appeal_to_higher_level_review) do
      described_class::INELIGIBLE_REASONS[:appeal_to_higher_level_review]
    end

    it "returns 'appeal_to_higher_level_review'" do
      expect(subject).to eq(appeal_to_higher_level_review)
    end
  end

  describe "#before_ama" do
    subject { builder.send(:before_ama) }
    let(:before_ama) { described_class::INELIGIBLE_REASONS[:before_ama] }

    it "returns 'before_ama'" do
      expect(subject).to eq(before_ama)
    end
  end

  describe "#legacy_issue_not_withdrawn" do
    subject { builder.send(:legacy_issue_not_withdrawn) }
    let(:legacy_issue_not_withdrawn) { described_class::INELIGIBLE_REASONS[:legacy_issue_not_withdrawn] }

    it "returns 'legacy_issue_not_withdrawn'" do
      expect(subject).to eq(legacy_issue_not_withdrawn)
    end
  end

  describe "#legacy_appeal_not_eligible" do
    subject { builder.send(:legacy_appeal_not_eligible) }
    let(:legacy_appeal_not_eligible) { described_class::INELIGIBLE_REASONS[:legacy_appeal_not_eligible] }

    it "returns 'legacy_appeal_not_eligible'" do
      expect(subject).to eq(legacy_appeal_not_eligible)
    end
  end

  describe "#handle_associated_request_issue_not_present" do
    subject { builder.send(:handle_associated_request_issue_not_present) }
    let(:logged_message) do
      "[Builders::DecisionReviewCreated::RequestIssueBuilder] Issue with contention id of 1 is "\
      "ineligible due to a pending review but has null for associated_caseflow_request_issue_id"
    end
    let(:note) do
      "Issue with contention id of 1 is ineligible due to a pending review but has null"\
      " for associated_caseflow_request_issue_id"
    end
    let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_board_appeal) }

    context "when there is not an associated_caseflow_request_issue_id present" do
      before do
        issue.contention_id = 1
        issue.associated_caseflow_request_issue_id = nil
      end

      it "logs 'Issue is ineligible due to a pending review but has null for associated_caseflow_request_issue_id'" do
        expect(Rails.logger).to receive(:info).with(logged_message)

        subject
      end

      it "updates the 'notes' column on the event_audit with the logged message" do
        subject
        expect(EventAudit.last.notes).to include(note)
      end
    end
  end

  describe "#remove_duplicate_prior_decision_type_text" do
    subject { builder.send(:remove_duplicate_prior_decision_type_text) }

    context "when the issue has nil for prior_decision_type" do
      before do
        issue.prior_decision_type = nil
      end

      it "returns issue.prior_decision_text" do
        expect(subject).to eq(issue.prior_decision_text)
      end
    end

    context "when the issue has prior_decision_type text within prior_decision_text" do
      before do
        issue.prior_decision_text = "DIC: something - DIC: something"
      end

      let(:expected_prior_decision_text) { "something - DIC: something" }

      it "removes the duplicate prior_decision_type text from prior_decision_text" do
        expect(subject).to eq(expected_prior_decision_text)
      end
    end

    context "when the issue DOES NOT have prior_decision_type text within prior_decision_text" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

      it "returns issue.prior_decision_text" do
        expect(subject).to eq(issue.prior_decision_text)
      end
    end
  end

  describe "rating_or_decision_issue?" do
    subject { builder.send(:rating_or_decision_issue?) }

    context "when the issue has a prior_rating_decision_id value" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a prior_decision_rating_sn value" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has an prior_caseflow_decision_issue_id value" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue does not have a not-null value for any of the attributes listed above" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#pending_claim_review?" do
    subject { builder.send(:pending_claim_review?) }
    context "when the issue's eligibility_result contains 'PENDING'" do
      context "PENDING_HLR" do
        let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "PENDING_BOARD_APPEAL" do
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_pending_board_appeal)
        end
        it "returns true" do
          expect(subject).to eq true
        end
      end

      context "PENDING_SUPPLEMENTAL" do
        let(:decision_review_model) do
          build(:decision_review_created, :ineligible_nonrating_hlr_pending_supplemental)
        end
        it "returns true" do
          expect(subject).to eq true
        end
      end
    end

    context "when the issue's eligibility_result DOES NOT contain 'PENDING'" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#time_restriction?" do
    subject { builder.send(:time_restriction?) }
    context "when the issue's eligibility_result is 'TIME_RESTRICTION'" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
      end
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT 'TIME_RESTRICTION'" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#pending_legacy_appeal?" do
    subject { builder.send(:pending_legacy_appeal?) }
    context "when the issue's eligibility_result is 'PENDING_LEGACY_APPEAL'" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_legacy_appeal) }
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT 'PENDIGN_LEGACY_APPEAL'" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#legacy_time_restriction_or_no_soc_ssoc?" do
    subject { builder.send(:legacy_time_restriction_or_no_soc_ssoc?) }
    context "when the issue's eligibility_result is 'LEGACY_TIME_RESTRICTION'" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_legacy_time_restriction)
      end
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is 'NO_SOC_SSOC'" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_no_soc_ssoc) }
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT 'LEGACY_TIME_RESTRICTION' or 'NO_SOC_SSOC" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#contested?" do
    subject { builder.send(:contested?) }
    context "when the issue's eligibility_result is 'CONTESTED'" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_contested)
      end
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT 'CONTESTED'" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#completed_board_appeal?" do
    subject { builder.send(:completed_board_appeal?) }
    context "when the issue's eligibility_result is 'completed_board_appeal'" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_completed_board_appeal)
      end
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT 'completed_board_appeal'" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  # TODO: change to new field used for prior_decision_date - 1 business day
  describe "#decision_date_before_ama?" do
    subject { builder.send(:decision_date_before_ama?) }
    context "when the issue's prior_decision_date is BEFORE February 19, 2019" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
      end
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's prior_decision_date is ON or AFTER February 19, 2019" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_untimely)
      end
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#associated_caseflow_request_issue_present?" do
    subject { builder.send(:associated_caseflow_request_issue_present?) }
    context "when the issue has a not-null value for associated_caseflow_request_issue_id" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_rating_hlr_pending_hlr) }
      it "retuns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for associated_caseflow_request_issue_id" do
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#identified?" do
    subject { builder.send(:identified?) }

    context "when the issue has an identifier" do
      context "prior_rating_decision_id" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
        it "retuns true" do
          expect(subject).to eq true
        end
      end

      context "prior_decision_rating_sn" do
        let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
        it "retuns true" do
          expect(subject).to eq true
        end
      end

      context "prior_non_rating_decision_id" do
        it "retuns true" do
          expect(subject).to eq true
        end
      end
    end

    context "when the issue is unidentified" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }
      it "retuns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#prior_decision_date_not_present?" do
    subject { builder.send(:prior_decision_date_not_present?) }
    context "when the issue has a not-null value for prior_decision_date" do
      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "when the issue has a null value for prior_decision_date" do
      before do
        issue.prior_decision_date = nil
      end

      it "returns true" do
        expect(subject).to eq true
      end
    end
  end

  describe "#contention_id_not_present?" do
    subject { builder.send(:contention_id_not_present?) }
    context "when the issue has a not-null value for contention_id" do
      it "returns false" do
        expect(subject).to eq false
      end
    end

    context "when the issue has a null value for contention_id" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end
  end

  describe "#ineligible?" do
    subject { builder.send(:ineligible?) }
    context "when the issue's eligibility_result is included in INELIGIBLE constant" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT included in INELIGIBLE constant" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#eligible?" do
    subject { builder.send(:eligible?) }

    context "when the issue's eligibility_result is included in ELIGIBLE constant" do
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue's eligibility_result is NOT included in ELIGIBLE constant" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#unidentified?" do
    subject { builder.send(:unidentified?) }
    context "when the issue has unidentified as true" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr_unidentified) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has unidentified as false" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#nonrating?" do
    subject { builder.send(:nonrating?) }
    context "when the issue has a not-null value for prior_non_rating_decision_id" do
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for prior_non_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#rating?" do
    subject { builder.send(:rating?) }
    context "when the issue has a not-null value for prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for prior_rating_decision_id" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#rating_decision?" do
    subject { builder.send(:rating_decision?) }
    context "when the issue has a not-null value for prior_decision_rating_sn" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for prior_decision_rating_sn" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#decision_issue?" do
    subject { builder.send(:decision_issue?) }
    context "when the issue has a not-null value for prior_caseflow_decision_issue_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_decision_issue_prior_nonrating_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for prior_decision_rating_sn" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#determine_benefit_type" do
    subject { builder.send(:determine_benefit_type) }
    context "when DecisionReviewCreated has an ep_code that includes 'PMC'" do
      let(:decision_review_model) { build(:decision_review_created, :nonrating_hlr_pension) }
      it "returns 'pension'" do
        expect(subject).to eq(described_class::PENSION_BENEFIT_TYPE)
      end
    end

    context "when DecisionReviewCreated has an ep_code that does not include 'PMC'" do
      it "returns 'compensation'" do
        expect(subject).to eq(described_class::COMPENSATION_BENEFIT_TYPE)
      end
    end
  end

  describe "#determine_pending_claim_review_type" do
    subject { builder.send(:determine_pending_claim_review_type) }

    context "when the issue has a not-null value for prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_rating_hlr_pending_hlr) }
      it "returns 'duplicate_of_rating_issue_in_active_review" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:duplicate_of_rating_issue_in_active_review])
      end
    end

    context "when the issue has a null value for prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_pending_hlr) }
      it "returns 'duplicate_of_nonrating_issue_in_active_review" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:duplicate_of_nonrating_issue_in_active_review])
      end
    end
  end

  describe "#determine_time_restriction_type" do
    subject { builder.send(:determine_time_restriction_type) }
    context "when the issue's prior_decision_date is BEFORE February 19, 2019" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_before_ama)
      end
      it "returns 'before_ama'" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:before_ama])
      end
    end

    context "when the issue's prior_decision_date is ON or AFTER February 19, 2019" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_time_restriction_untimely)
      end
      it "returns 'untimely'" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:untimely])
      end
    end
  end

  describe "#completed_claim_review?" do
    subject { builder.send(:completed_claim_review?) }
    context "when the issue has an eligibility_result that is listed in the COMPLETED_REVIEW constant" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_completed_board_appeal)
      end
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue does not have an eligibility_result that is listed in the COMPLETED_REVIEW constant" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#determine_completed_claim_review_type" do
    subject { builder.send(:determine_completed_claim_review_type) }
    context "when the issue's eligibility_result is 'completed_board_appeal'" do
      let(:decision_review_model) do
        build(:decision_review_created, :ineligible_nonrating_hlr_completed_board_appeal)
      end
      it "returns 'appeal_to_higher_level_review'" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:appeal_to_higher_level_review])
      end
    end

    context "when the issue's eligibility_result is 'COMPLETED_HLR'" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_completed_hlr) }
      it "returns 'higher_level_review_to_higher_level_review'" do
        expect(subject).to eq(described_class::INELIGIBLE_REASONS[:higher_level_review_to_higher_level_review])
      end
    end
  end

  describe "#handle_unrecognized_eligibility_result" do
    before do
      issue.eligibility_result = "UNKNOWN"
    end

    subject { builder.send(:handle_unrecognized_eligibility_result) }
    let(:error) { AppealsConsumer::Error::IssueEligibilityResultNotRecognized }
    let(:error_msg) do
      "Issue has an unrecognized eligibility_result: #{issue.eligibility_result}"
    end

    it "raises AppealsConsumer::Error::IssueEligibilityResultNotRecognized with message" do
      expect { subject }.to raise_error(error, error_msg)
    end
  end

  describe "#handle_missing_contention_id" do
    subject { builder.send(:handle_missing_contention_id) }
    let(:error) { AppealsConsumer::Error::NullContentionIdError }
    let(:error_msg) do
      "Issue is eligible but has null for contention_id"
    end

    it "raises AppealsConsumer::Error::NullContentionIdError with message" do
      expect { subject }.to raise_error(error, error_msg)
    end
  end

  describe "#handle_missing_decision_date" do
    subject { builder.send(:handle_missing_decision_date) }
    let(:error) { AppealsConsumer::Error::NullPriorDecisionDate }
    let(:error_msg) do
      "Issue with contention_id #{issue.contention_id} is identified but has null for prior_decision_date"
    end

    it "raises AppealsConsumer::Error::NullPriorDecisionDate" do
      expect { subject }.to raise_error(error, error_msg)
    end
  end

  describe "#contention_id_present?" do
    subject { builder.send(:contention_id_present?) }
    context "when the issue has a not null value for contention_id" do
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a null value for contention_id" do
      let(:decision_review_model) { build(:decision_review_created, :ineligible_nonrating_hlr_completed_hlr) }
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#rating_or_rating_decision?" do
    subject { builder.send(:rating_or_rating_decision?) }

    context "when the issue has a value for prior_rating_decision_id" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue has a value for prior_decision_rating_sn" do
      let(:decision_review_model) { build(:decision_review_created, :eligible_rating_decision_hlr) }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue does not have a value for prior_rating_decision_id or"\
     " prior_decision_rating_sn" do
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#prior_decision_date_converted_to_logical_type" do
    subject { prior_decision_date_converted_to_logical_type }

    context "when the value is nil" do
      before do
        issue.prior_decision_date = nil
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when the value is not nil" do
      it "returns the value converted to an integer" do
        expect(subject.class).to eq(Integer)
      end
    end
  end

  describe "#determine_ramp_claim_id" do
    subject { builder.send(:determine_ramp_claim_id) }
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

    context "when @bis_rating_profiles or associated_claims_data is nil" do
      context "@bis_rating_profiles is nil" do
        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "@associated_claims_data is nil" do
        before do
          allow(builder).to receive(:associated_claims_data).and_return(nil)
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when @bis_rating_profiles and associated_claims_data are not nil" do
      context "when associated_ramp_ep is nil" do
        let(:bis_rating_profiles) do
          {
            rba_claim_list: {
              rba_claim: {
                bnft_clm_tc: "030HLRR",
                clm_id: "1002003",
                prfl_date: Date.new(1980, 1, 1)
              }
            }
          }
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "when associated_ramp_ep is not nil" do
        let(:bis_rating_profiles) do
          {
            rba_claim_list: {
              rba_claim: {
                bnft_clm_tc: "682HLRRRAMP",
                clm_id: "1002003",
                prfl_date: issue.prior_decision_rating_profile_date.to_date
              }
            }
          }
        end

        it "returns the clm_id of the RAMP ep" do
          expect(subject).to eq("1002003")
        end
      end
    end
  end

  describe "#associated_claims_data" do
    subject { builder.send(:associated_claims_data) }
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

    context "when there isn't a key rba_claim_list containg a hash with key rba_claim" do
      let(:bis_rating_profiles) do
        {
          rba_issue_list: {
            rba_issue: {
              rba_issue_id: "123456",
              prfil_date: Date.new(1980, 1, 1)
            }
          }
        }
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when key is found at rba_claim_list, rba_claim" do
      context "when rba_claim key has nil value" do
        let(:bis_rating_profiles) do
          {
            rba_issue_list: {
              rba_issue: {
                rba_issue_id: "123456",
                prfil_date: Date.new(1980, 1, 1)
              }
            },
            rba_claim_list: {
              rba_claim: nil
            }
          }
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "when rba_claim key does not have nil value" do
        context "when no claims have a prfl_date matching the issue's prior_decision_rating_profile_date" do
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: "123456",
                  prfil_date: Date.new(1980, 1, 1)
                }
              },
              rba_claim_list: {
                rba_claim: {
                  bnft_clm_tc: "030HLRR",
                  clm_id: "1002003",
                  prfl_date: Date.new(1980, 1, 1)
                }
              }
            }
          end

          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end

        context "when there are multiple claims that have a prfl_date matching the"\
          " issue's prior_decision_rating_profile_date" do
          let(:issue_profile_date) { issue.prior_decision_rating_profile_date }
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: issue.prior_rating_decision_id,
                  prfil_date: issue_profile_date.to_date
                }
              },
              rba_claim_list: {
                rba_claim: [
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: issue_profile_date.to_date
                  },
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: issue_profile_date.to_date
                  }
                ]
              }
            }
          end

          it "returns an array with both claim objects" do
            expect(subject).to eq(bis_rating_profiles[:rba_claim_list][:rba_claim])
          end
        end

        context "when there are multiple claims and only one that have a prfl_date matching the"\
          " issue's prior_decision_rating_profile_date" do
          let(:issue_profile_date) { issue.prior_decision_rating_profile_date }
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: issue.prior_rating_decision_id,
                  prfil_date: issue_profile_date.to_date
                }
              },
              rba_claim_list: {
                rba_claim: [
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: Date.new(1980, 1, 1)
                  },
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: issue_profile_date.to_date
                  }
                ]
              }
            }
          end

          it "returns an array with one claim object" do
            expect(subject).to eq([bis_rating_profiles[:rba_claim_list][:rba_claim][1]])
          end
        end

        context "when there is only one claim and it has a prfl_date matching the"\
        " issue's prior_decision_rating_profile_date" do
          let(:issue_profile_date) { issue.prior_decision_rating_profile_date }
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: issue.prior_rating_decision_id,
                  prfil_date: issue_profile_date.to_date
                }
              },
              rba_claim_list: {
                rba_claim: {
                  bnft_clm_tc: "030HLRR",
                  clm_id: "1002003",
                  prfl_date: issue.prior_decision_rating_profile_date
                }
              }
            }
          end

          it "returns an array with one claim object" do
            expect(subject).to eq([bis_rating_profiles[:rba_claim_list][:rba_claim]])
          end
        end
      end
    end
  end

  describe "#find_all_claims" do
    subject { builder.send(:find_all_claims) }
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

    context "when key does not exist at rba_claim_list, rba_key" do
      let(:bis_rating_profiles) do
        {
          rba_issue_list: {
            rba_issue: {
              rba_issue_id: "123456",
              prfil_date: Date.new(1980, 1, 1)
            }
          }
        }
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when key exists at rba_claim_list, rba_key" do
      context "when rba_claim has nil value" do
        let(:bis_rating_profiles) do
          {
            rba_issue_list: {
              rba_issue: {
                rba_issue_id: "123456",
                prfil_date: Date.new(1980, 1, 1)
              }
            },
            rba_claim_list: {
              rba_claim: nil
            }
          }
        end

        it "returns nil" do
          expect(subject).to eq nil
        end
      end

      context "when rba_claim has not nil value" do
        context "when the value is an object" do
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: "12345",
                  prfil_date: Date.new(1970, 1, 1)
                }
              },
              rba_claim_list: {
                rba_claim: {
                  bnft_clm_tc: "030HLRR",
                  clm_id: "1002003",
                  prfl_date: Date.new(1970, 1, 1)
                }
              }
            }
          end

          it "returns the claim wrapped in an array" do
            expect(subject).to eq([bis_rating_profiles[:rba_claim_list][:rba_claim]])
          end
        end

        context "when the value is an array of objects" do
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: "1234",
                  prfil_date: Date.new(1970, 1, 1)
                }
              },
              rba_claim_list: {
                rba_claim: [
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: Date.new(1980, 1, 1)
                  },
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: Date.new(1970, 1, 1)
                  }
                ]
              }
            }
          end

          it "returns the value of rba_claim" do
            expect(subject).to eq(bis_rating_profiles[:rba_claim_list][:rba_claim])
          end
        end

        context "when rba_claims are in different objects" do
          let(:bis_rating_profiles) do
            {
              rba_issue_list: {
                rba_issue: {
                  rba_issue_id: "1234",
                  prfil_date: Date.new(1970, 1, 1)
                }
              },
              rba_claim_list: {
                rba_claim: [
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002003",
                    prfl_date: Date.new(1980, 1, 1)
                  },
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002001",
                    prfl_date: Date.new(1970, 1, 1)
                  }
                ]
              },
              rba_claim_list2: {
                rba_claim: [
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002004",
                    prfl_date: Date.new(1980, 1, 1)
                  },
                  {
                    bnft_clm_tc: "030HLRR",
                    clm_id: "1002002",
                    prfl_date: Date.new(1970, 1, 1)
                  }
                ]
              }
            }
          end
          it "returns the value of all rba_claims" do
            expect(subject).to eq(bis_rating_profiles[:rba_claim_list][:rba_claim]
              .push(bis_rating_profiles[:rba_claim_list2][:rba_claim]).flatten)
          end
        end
      end
    end
  end

  describe "#find_associated_claims(all_claims)" do
    subject { builder.send(:find_associated_claims, all_claims) }
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }
    context "when there aren't any claims that match the issue's prior_decision_rating_profile_date" do
      let(:all_claims) do
        [
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: Date.new(1980, 1, 1)
          }
        ]
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when there is at least one claim that match the issue's prior_decision_rating_profile_date" do
      let(:all_claims) do
        [
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date.to_date
          },
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: Date.new(1980, 1, 1)
          }
        ]
      end

      it "returns an array of the matching claims" do
        expect(subject.count).to eq(1)
      end
    end
  end

  describe "#claim_profile_date_matches_issue_profile_date?(claim)" do
    subject { builder.send(:claim_profile_date_matches_issue_profile_date?, claim) }
    let(:decision_review_model) { build(:decision_review_created, :eligible_rating_hlr) }

    context "when claim[:prfl_date] or issue.prior_decision_rating_profile_date are nil" do
      context "when claim[:prfl_date] is nil" do
        let(:claim) do
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: nil
          }
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end

      context "when issue.prior_decision_rating_profile_date is nil" do
        let(:claim) do
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: Date.new(1970, 1, 1)
          }
        end

        before do
          issue.prior_decision_rating_profile_date = nil
        end

        it "returns nil" do
          expect(subject).to eq(nil)
        end
      end
    end

    context "when claim[:prfl_date] and issue.prior_decision_rating_profile_date are both not-nil" do
      context "when claim[:prfl_date] does not match issue.prior_decision_rating_profile_date" do
        let(:claim) do
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: Date.new(1970, 1, 1)
          }
        end

        it "returns false" do
          expect(subject).to eq(false)
        end
      end

      context "when claim[:prfl_date] matches issue.prior_decision_rating_profile_date" do
        let(:claim) do
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        end

        it "returns true" do
          expect(subject).to eq(true)
        end
      end
    end
  end

  describe "find_associated_ramp_ep(associated_claims_data)" do
    subject { builder.send(:find_associated_ramp_ep, associated_claims_data) }
    context "when one of the associated claims contains nil for bnft_clm_tc and the other is non-ramp" do
      let(:associated_claims_data) do
        [
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          },
          {
            bnft_clm_tc: nil,
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        ]
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when one of the associated claims contains nil for bnft_clm_tc and the other is ramp" do
      let(:associated_claims_data) do
        [
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          },
          {
            bnft_clm_tc: "682HLRRRAMP",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        ]
      end

      it "returns the claim with ramp ep code" do
        expect(subject).to eq(associated_claims_data[1])
      end
    end

    context "when none of the associated claims contain a RAMP ep code" do
      let(:associated_claims_data) do
        [
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          },
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        ]
      end

      it "returns nil" do
        expect(subject).to eq nil
      end
    end

    context "when one of the associated claims contain a RAMP ep code" do
      let(:associated_claims_data) do
        [
          {
            bnft_clm_tc: "682HLRRRAMP",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          },
          {
            bnft_clm_tc: "030HLRR",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        ]
      end

      it "returns the obj with the RAMP ep" do
        expect(subject).to eq(associated_claims_data[0])
      end
    end

    context "when multiple associated claims contain a RAMP ep code" do
      let(:associated_claims_data) do
        [
          {
            bnft_clm_tc: "682HLRRRAMP",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          },
          {
            bnft_clm_tc: "682HLRRRAMP",
            clm_id: "1002003",
            prfl_date: issue.prior_decision_rating_profile_date
          }
        ]
      end

      it "returns the first obj with the RAMP ep" do
        expect(subject).to eq(associated_claims_data[0])
      end
    end
  end
end
