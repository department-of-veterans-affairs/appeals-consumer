# frozen_string_literal: true

describe KafkaMessageGenerators::DecisionReviewCreatedEvents do
  let(:decision_review_created_events) { described_class.new }
  let(:decision_review_created) { build(:decision_review_created) }
  let(:rating_ep_codes) { decision_review_created_events.send(:rating_ep_codes) }
  let(:nonrating_ep_codes) { decision_review_created_events.send(:nonrating_ep_codes) }
  let(:sc_rating_ep_codes) { decision_review_created_events.send(:sc_rating_ep_codes) }
  let(:hlr_rating_ep_codes) { decision_review_created_events.send(:hlr_rating_ep_codes) }
  let(:sc_rating_ep_code) { "040SCR" }
  let(:hlr_rating_ep_code) { "030HLRR" }
  let(:sc_nonrating_ep_codes) { decision_review_created_events.send(:sc_nonrating_ep_codes) }
  let(:hlr_nonrating_ep_codes) { decision_review_created_events.send(:hlr_nonrating_ep_codes) }
  let(:sc_nonrating_ep_code) { "040SCNR" }
  let(:hlr_nonrating_ep_code) { "030HLRNR" }
  let(:ep_codes) { described_class::EP_CODES }
  let(:issue_type) { "rating_hlr" }
  let(:issue_trait) { "eligible_rating_hlr" }
  let(:code) { hlr_rating_ep_code }
  let(:veteran_bis_record) do
    {
      file_number: decision_review_created.file_number,
      ptcpnt_id: decision_review_created.veteran_participant_id,
      sex: "M",
      first_name: decision_review_created.veteran_first_name,
      middle_name: "Russell",
      last_name: decision_review_created.veteran_last_name,
      name_suffix: "II",
      ssn: "987654321",
      address_line1: "122 Mullberry St.",
      address_line2: "PO BOX 123",
      address_line3: "Daisies",
      city: "Orlando",
      state: "FL",
      country: "USA",
      date_of_birth: "12/21/1989",
      date_of_death: "12/31/2019",
      zip_code: "94117",
      military_post_office_type_code: nil,
      military_postal_type_code: nil,
      service: [{ branch_of_service: "army", pay_grade: "E4" }]
    }
  end

  describe "#initialize" do
    subject { decision_review_created_events }
    before do
      Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
    end

    it "clears the cache" do
      subject
      expect(Fakes::VeteranStore.new.all_veteran_file_numbers).to be_empty
    end

    it "creates an array instance variable called file_numbers_to_remove_from_cache" do
      expect(subject.instance_variable_get(:@file_numbers_to_remove_from_cache)).to eq([])
    end
  end

  describe "#publish_messages" do
    subject { decision_review_created_events.publish_messages! }
    before do
      allow(Karafka.producer).to receive(:produce_sync)
    end

    it "publishes 5897 messages to the DecisionReviewCreated topic" do
      subject
      expect(Karafka.producer).to have_received(:produce_sync).exactly(5897).times do |args|
        expect(args[:topic]).to eq("VBMS_CEST_UAT_DECISION_REVIEW_INTAKE")
      end
    end
  end

  describe "#clear_cache" do
    subject { decision_review_created_events.send(:clear_cache) }

    before do
      Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
    end

    it "clears the cache" do
      subject
      expect(Fakes::VeteranStore.new.all_veteran_file_numbers).to be_empty
    end
  end

  describe "#sc_issue?(ep_code)" do
    subject { decision_review_created_events.send(:sc_issue?, ep_code) }
    context "when the message is a supplemental claim" do
      let(:ep_code) { sc_rating_ep_code }
      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the message is a higher level review" do
      let(:ep_code) { hlr_rating_ep_code }
      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#create_messages" do
    subject { decision_review_created_events.send(:create_messages) }
    it "creates 5897 messages" do
      expect(subject.flatten.count).to eq(5897)
    end
  end

  describe "#create_rating_messages" do
    subject { decision_review_created_events.send(:create_rating_messages) }
    it "creates 2849 rating messages" do
      expect(subject.flatten.count).to eq(2849)
    end
  end

  describe "#create_nonrating_messages" do
    subject { decision_review_created_events.send(:create_nonrating_messages) }
    it "creates 3048 rating messages" do
      expect(subject.flatten.count).to eq(3048)
    end
  end

  describe "#create_rating_ep_code_messages(ep_codes)" do
    subject { decision_review_created_events.send(:create_rating_ep_code_messages, rating_ep_codes) }
    it "creates 2849 rating messages" do
      expect(subject.flatten.count).to eq(2849)
    end
  end

  describe "#create_rating_issue_type_messages(code)" do
    subject { decision_review_created_events.send(:create_rating_issue_type_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_rating_ep_code }
      it "creates 79 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(79)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_rating_ep_code }
      it "creates 85 messages for the hlr rating ep code" do
        expect(subject.flatten.count).to eq(85)
      end
    end
  end

  describe "#create_hlr_rating_issue_messages(code)" do
    subject { decision_review_created_events.send(:create_hlr_rating_issue_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_rating_ep_code }
      it "creates 26 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(26)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_rating_ep_code }
      it "creates 28 messages for each hlr rating ep code" do
        expect(subject.flatten.count).to eq(28)
      end
    end
  end

  describe "#create_hlr_rating_decision_messages(code)" do
    subject { decision_review_created_events.send(:create_hlr_rating_decision_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_rating_ep_code }
      it "creates 21 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(21)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_rating_ep_code }
      it "creates 23 messages for the hlr rating ep code" do
        expect(subject.flatten.count).to eq(23)
      end
    end
  end

  describe "#create_hlr_decision_issue_prior_rating_messages(code)" do
    subject do
      decision_review_created_events.send(:create_hlr_decision_issue_prior_rating_messages, code)
    end

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_rating_ep_code }
      it "creates 23 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(23)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_rating_ep_code }
      it "creates 25 messages for the hlr rating ep code" do
        expect(subject.flatten.count).to eq(25)
      end
    end
  end

  describe "#create_hlr_unidentified_rating_messages(code)" do
    subject do
      decision_review_created_events.send(:create_hlr_unidentified_rating_messages, code)
    end

    let(:code) { hlr_rating_ep_code }
    it "creates 9 messages for the rating ep code" do
      expect(subject.flatten.count).to eq(9)
    end
  end

  describe "#rating_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:rating_messages, issue_type, code) }

    context "when the issue is unidentified" do
      let(:issue_type) { "rating_hlr_unidentified" }
      let(:code) { hlr_rating_ep_code }
      it "creates 9 messages for the rating ep code" do
        expect(subject.flatten.count).to eq(9)
      end
    end

    context "when the issue is identified" do
      context "when the decision review is a supplemental claim" do
        let(:code) { sc_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 26 messages for the rating issue" do
            expect(subject.flatten.count).to eq(26)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 21 messages for the rating issue" do
            expect(subject.flatten.count).to eq(21)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 23 messages for the rating issue" do
            expect(subject.flatten.count).to eq(23)
          end
        end
      end

      context "when the decision review is a higher level review" do
        let(:code) { hlr_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 28 messages for the rating issue" do
            expect(subject.flatten.count).to eq(28)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 23 messages for the rating issue" do
            expect(subject.flatten.count).to eq(23)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 25 messages for the rating issue" do
            expect(subject.flatten.count).to eq(25)
          end
        end
      end
    end
  end

  describe "#create_rating_eligible_messages(issue_type, code)" do
    subject do
      decision_review_created_events.send(:create_rating_eligible_messages, issue_type, code)
    end

    context "when the issue is unidentified" do
      let(:issue_type) { "rating_hlr_unidentified" }
      let(:code) { sc_rating_ep_code }
      it "creates 6 messages for the rating ep code" do
        expect(subject.flatten.count).to eq(6)
      end
    end

    context "when the issue is identified" do
      context "when the decision review is a supplemental claim" do
        let(:code) { sc_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 12 messages for the rating issue" do
            expect(subject.flatten.count).to eq(12)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 8 messages for the rating issue" do
            expect(subject.flatten.count).to eq(8)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 10 messages for the rating issue" do
            expect(subject.flatten.count).to eq(10)
          end
        end
      end

      context "when the decision review is a higher level review" do
        let(:code) { hlr_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 12 messages for the rating issue" do
            expect(subject.flatten.count).to eq(12)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 8 messages for the rating issue" do
            expect(subject.flatten.count).to eq(8)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 10 messages for the rating issue" do
            expect(subject.flatten.count).to eq(10)
          end
        end
      end
    end
  end

  describe "#create_rating_invalid_messages(issue_type, code)" do
    subject do
      decision_review_created_events.send(:create_rating_invalid_messages, issue_type, code)
    end

    context "when the issue is unidentified" do
      let(:issue_type) { "rating_hlr_unidentified" }
      let(:code) { sc_rating_ep_code }
      it "creates 3 messages for the rating ep code" do
        expect(subject.flatten.count).to eq(3)
      end
    end

    context "when the issue is identified" do
      context "when the decision review is a supplemental claim" do
        let(:code) { sc_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 6 messages for the rating issue" do
            expect(subject.flatten.count).to eq(6)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 5 messages for the rating issue" do
            expect(subject.flatten.count).to eq(5)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 5 messages for the rating issue" do
            expect(subject.flatten.count).to eq(5)
          end
        end
      end

      context "when the decision review is a higher level review" do
        let(:code) { hlr_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 6 messages for the rating issue" do
            expect(subject.flatten.count).to eq(6)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 5 messages for the rating issue" do
            expect(subject.flatten.count).to eq(5)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 5 messages for the rating issue" do
            expect(subject.flatten.count).to eq(5)
          end
        end
      end
    end
  end

  describe "#create_valid_and_eligible_rating_messages(issue_type, code)" do
    subject do
      decision_review_created_events.send(:create_valid_and_eligible_rating_messages, issue_type, code)
    end

    context "when the issue is unidentified" do
      let(:issue_type) { "rating_hlr_unidentified" }
      let(:code) { sc_rating_ep_code }
      it "creates 6 messages for the rating ep code" do
        expect(subject.flatten.count).to eq(6)
      end
    end

    context "when the issue is identified" do
      context "when the decision review is a supplemental claim" do
        let(:code) { sc_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 12 messages for the rating issue" do
            expect(subject.flatten.count).to eq(12)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 8 messages for the rating issue" do
            expect(subject.flatten.count).to eq(8)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 10 messages for the rating issue" do
            expect(subject.flatten.count).to eq(10)
          end
        end
      end

      context "when the decision review is a higher level review" do
        let(:code) { hlr_rating_ep_code }

        context "when the issue is a rating issue" do
          let(:issue_type) { "rating_hlr" }
          it "creates 12 messages for the rating issue" do
            expect(subject.flatten.count).to eq(12)
          end
        end

        context "when the issue is a rating decision" do
          let(:issue_type) { "rating_decision_hlr" }
          it "creates 8 messages for the rating issue" do
            expect(subject.flatten.count).to eq(8)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_rating_hlr" }
          it "creates 10 messages for the rating issue" do
            expect(subject.flatten.count).to eq(10)
          end
        end
      end
    end
  end

  describe "#create_unidentified_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_unidentified_messages, issue_type, code) }
    it "creates 6 messages for the rating or nonrating ep code" do
      expect(subject.flatten.count).to eq(6)
    end
  end

  describe "#create_drc_message_with_poa_access(issue_trait, code)" do
    subject { decision_review_created_events.send(:create_drc_message_with_poa_access, issue_trait, code) }

    it "creates a message with odd claim_id" do
      expect(subject.claim_id.odd?).to be true
    end

    it "adds 2 to @with_poa_access_claim_id after each record" do
      subject
      expect(decision_review_created_events.instance_variable_get(:@with_poa_access_claim_id)).to eq(3)
    end
  end

  describe "#create_drc_message_without_poa_access(issue_trait, code)" do
    subject { decision_review_created_events.send(:create_drc_message_without_poa_access, issue_trait, code) }

    it "creates a message with even claim_id" do
      expect(subject.claim_id.even?).to be true
    end

    it "adds 2 to @with_poa_access_claim_id after each record" do
      subject
      expect(decision_review_created_events.instance_variable_get(:@without_poa_access_claim_id)).to eq(4)
    end
  end

  describe "#create_drc_message_with_nil_poa_access(issue_trait, code)" do
    subject { decision_review_created_events.send(:create_drc_message_with_nil_poa_access, issue_trait, code) }

    it "creates a message with claim_id 0" do
      expect(subject.claim_id).to eq(0)
    end

    it "@nil_poa_access_claim_id remains 0 after each record" do
      subject
      expect(decision_review_created_events.instance_variable_get(:@nil_poa_access_claim_id)).to eq(0)
    end
  end

  describe "#set_claim_id(drc, claim_id_int)" do
    subject { decision_review_created_events.send(:set_claim_id, drc, claim_id_int) }
    let(:drc) { decision_review_created }
    let(:claim_id_int) { 4 }

    it "sets the DecisionReviewCreated's claim id to the integer passed in" do
      expect(subject).to eq(4)
    end
  end

  describe "#create_identified_messages(issue_type, code, valid_unidentified_messages)" do
    subject do
      decision_review_created_events.send(:create_identified_messages, issue_type, code, valid_unidentified_messages)
    end

    let(:valid_unidentified_messages) { build_list(:decision_review_created, 2) }

    it "creates two messages and returns the two messages plus valid_unidentified_messages" do
      expect(subject.flatten.count).to eq(4)
    end
  end

  describe "#create_assoc_decision_issue_messages(issue_type, code, rating_decision_messages)" do
    subject do
      decision_review_created_events
        .send(:create_assoc_decision_issue_messages, issue_type, code, rating_decision_messages)
    end

    let(:rating_decision_messages) { build_list(:decision_review_created, 2) }

    it "creates one message and returns that message plus rating_decision_messages" do
      expect(subject.flatten.count).to eq(4)
    end
  end

  describe "#create_invalid_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_invalid_messages, issue_type, code) }

    context "when the issue is unidentified" do
      let(:issue_type) { "rating_hlr_unidentified" }
      it "creates 3 messages" do
        expect(subject.flatten.count).to eq(3)
      end
    end

    context "when the issue is a rating decision or has an associated decision issue" do
      let(:issue_type) { "rating_decision_hlr" }
      it "creates 5 messages" do
        expect(subject.flatten.count).to eq(5)
      end
    end

    context "when the issue is identified and does not contain an associated decision issue" do
      it "creates 6 messages" do
        expect(subject.flatten.count).to eq(6)
      end
    end
  end

  describe "#create_contested_issue(issue_type, code)" do
    subject { decision_review_created_events.send(:create_contested_issue, issue_type, code) }
    let(:decision_review_issues) do
      subject.first.decision_review_issues
    end

    it "creates 1 message with eligibility_result 'CONTESTED'" do
      expect(subject.count).to eq(1)
      expect(decision_review_issues.all? { |issue| issue.eligibility_result == "CONTESTED" }).to eq true
    end
  end

  describe "#create_invalid_unidentified_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_invalid_unidentified_messages, issue_type, code) }

    it "creates 3 messages" do
      expect(subject.flatten.count).to eq(3)
    end
  end

  describe "#create_invalid_identified_messages(issue_type code, invalid_unidentified_messages)" do
    subject do
      decision_review_created_events.send(
        :create_invalid_identified_messages,
        issue_type,
        code,
        invalid_unidentified_messages
      )
    end

    let(:invalid_unidentified_messages) { build_list(:decision_review_created, 2) }

    it "returns 2 messages plus invalid_unidentified_messages" do
      expect(subject.flatten.count).to eq(4)
    end
  end

  describe "#create_ineligible_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_ineligible_messages, issue_type, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_rating_ep_code }

      it "creates 8 messages" do
        expect(subject.flatten.count).to eq(8)
      end
    end

    context "when the decision review is a higher level review" do
      it "creates 10 messages" do
        expect(subject.flatten.count).to eq(10)
      end
    end
  end

  describe "#create_ineligible_supp_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_ineligible_supp_messages, issue_type, code) }
    let(:code) { sc_rating_ep_code }
    it "creates 8 messages for the supplemental ep code" do
      expect(subject.flatten.count).to eq(8)
    end
  end

  describe "#create_ineligible_hlr_messages(issue_type, code, ineligible_supp_messages)" do
    subject do
      decision_review_created_events.send(:create_ineligible_hlr_messages, issue_type, code, ineligible_supp_messages)
    end

    let(:ineligible_supp_messages) { build_list(:decision_review_created, 2) }

    it "creates 2 messages plus ineligible_supp_messages" do
      expect(subject.flatten.count).to eq(4)
    end
  end

  describe "#create_drc_message_and_track_file_number(issue_trait, code)" do
    subject { decision_review_created_events.send(:create_drc_message_and_track_file_number, issue_trait, code) }
    let(:file_numbers_to_remove_from_cache) do
      decision_review_created_events.instance_variable_get(:@file_numbers_to_remove_from_cache)
    end

    it "creates a message and adds file number to @file_numbers_to_remove_from_cache array" do
      expect(file_numbers_to_remove_from_cache.include?(subject.file_number)).to eq true
    end
  end

  describe "#randomize_and_track_file_number(drc)" do
    subject { decision_review_created_events.send(:randomize_and_track_file_number, drc) }
    let(:drc) { decision_review_created }
    let(:file_numbers_to_remove_from_cache) do
      decision_review_created_events.instance_variable_get(:@file_numbers_to_remove_from_cache)
    end

    it "sets the message's file number to a random value" do
      expect(drc.file_number).not_to eq(subject.file_number)
    end

    it "adds file number to @file_numbers_to_remove_from_cache array" do
      expect(file_numbers_to_remove_from_cache.include?(subject.file_number)).to eq true
    end
  end

  describe "#create_drc_message_without_bis_person(issue_trait, code)" do
    subject { decision_review_created_events.send(:create_drc_message_without_bis_person, issue_trait, code) }

    it "changes the claimant_participant_id to an empty string" do
      expect(subject.claimant_participant_id).to eq("")
    end
  end

  describe "#create_drc_message(trait, ep_code)" do
    subject { decision_review_created_events.send(:create_drc_message, trait, ep_code) }
    let(:trait) { "eligible_rating_hlr_veteran_claimant" }
    let(:ep_code) { code }
    let(:initial_vet_claimant) { build(:decision_review_created, trait) }

    it "creates a DecisionReviewCreated record with the given trait and ep_code" do
      expect(subject.veteran_participant_id).to eq(subject.claimant_participant_id)
    end

    it "randomizes the claim_id" do
      expect(initial_vet_claimant.claim_id).not_to eq(subject.claim_id)
    end

    it "stores the veteran record in the cache" do
      expect(Fakes::VeteranStore.new.all_veteran_file_numbers.include?(subject.file_number)).to eq true
    end
  end

  describe "#create_nonrating_ep_code_messages(ep_codes)" do
    subject { decision_review_created_events.send(:create_nonrating_ep_code_messages, ep_codes) }
    let(:ep_codes) { nonrating_ep_codes }

    it "creates 3048 messages" do
      expect(subject.flatten.count).to eq(3048)
    end
  end

  describe "#create_nonrating_issue_type_messages(code)" do
    subject { decision_review_created_events.send(:create_nonrating_issue_type_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_nonrating_ep_code }
      it "creates 88 messages for the sc nonrating ep code" do
        expect(subject.flatten.count).to eq(88)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_nonrating_ep_code }
      it "creates 92 messages for the hlr nonrating ep code" do
        expect(subject.flatten.count).to eq(92)
      end
    end
  end

  describe "#create_nonrating_issue_messages(code)" do
    subject { decision_review_created_events.send(:create_nonrating_issue_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_nonrating_ep_code }
      it "creates 58 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(58)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_nonrating_ep_code }
      it "creates 60 messages for each hlr rating ep code" do
        expect(subject.flatten.count).to eq(60)
      end
    end
  end

  describe "#create_decision_issue_prior_nonrating_messages(code)" do
    subject { decision_review_created_events.send(:create_decision_issue_prior_nonrating_messages, code) }

    context "when the decision review is a supplemental claim" do
      let(:code) { sc_nonrating_ep_code }
      it "creates 21 messages for the sc rating ep code" do
        expect(subject.flatten.count).to eq(21)
      end
    end

    context "when the decision review is a higher level review" do
      let(:code) { hlr_nonrating_ep_code }
      it "creates 23 messages for each hlr rating ep code" do
        expect(subject.flatten.count).to eq(23)
      end
    end
  end

  describe "#create_unidentified_nonrating_messages(code)" do
    subject { decision_review_created_events.send(:create_unidentified_nonrating_messages, code) }
    let(:code) { sc_nonrating_ep_code }

    it "creates 9 messages regardless of decision review type" do
      expect(subject.flatten.count).to eq(9)
    end
  end

  describe "#nonrating_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:nonrating_messages, issue_type, code) }
    let(:code) { hlr_nonrating_ep_code }

    context "when the issue is unidentified" do
      let(:issue_type) { "nonrating_hlr_unidentified" }
      let(:code) { hlr_nonrating_ep_code }
      it "creates 9 messages for the nonrating ep code" do
        expect(subject.flatten.count).to eq(9)
      end
    end

    context "when the issue is identified" do
      context "when the decision review is a supplemental claim" do
        let(:code) { sc_nonrating_ep_code }

        context "when the issue is a nonrating issue" do
          let(:issue_type) { "nonrating_hlr" }
          it "creates 58 messages for the nonrating issue" do
            expect(subject.flatten.count).to eq(58)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_nonrating_hlr" }
          it "creates 21 messages for the nonrating issue" do
            expect(subject.flatten.count).to eq(21)
          end
        end
      end

      context "when the decision review is a higher level review" do
        let(:code) { hlr_nonrating_ep_code }

        context "when the issue is a nonrating issue" do
          let(:issue_type) { "nonrating_hlr" }
          it "creates 60 messages for the nonrating issue" do
            expect(subject.flatten.count).to eq(60)
          end
        end

        context "when the issue has an associated decision issue" do
          let(:issue_type) { "decision_issue_prior_nonrating_hlr" }
          it "creates 23 messages for the nonrating issue" do
            expect(subject.flatten.count).to eq(23)
          end
        end
      end
    end
  end

  describe "#create_nonrating_eligible_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_nonrating_eligible_messages, issue_type, code) }
    let(:code) { hlr_nonrating_ep_code }
    context "when the issue is unidentified" do
      let(:issue_type) { "nonrating_hlr_unidentified" }
      it "creates 6 messages" do
        expect(subject.flatten.count).to eq(6)
      end
    end

    context "when the issue is identified" do
      context "when the issue has an associated decision issue" do
        let(:issue_type) { "decision_issue_prior_nonrating_hlr" }
        it "creates 8 messages" do
          expect(subject.flatten.count).to eq(8)
        end
      end

      context "when the issue does not have an associated decision issue" do
        let(:issue_type) { "nonrating_hlr" }
        it "creates 44 messages" do
          expect(subject.flatten.count).to eq(44)
        end
      end
    end
  end

  describe "#create_nonrating_invalid_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_nonrating_invalid_messages, issue_type, code) }
    let(:code) { hlr_nonrating_ep_code }

    context "when the issue is unidentified" do
      let(:issue_type) { "nonrating_hlr_unidentified" }
      it "creates 3 messages" do
        expect(subject.flatten.count).to eq(3)
      end
    end

    context "when the issue has an associated decision issue" do
      let(:issue_type) { "decision_issue_prior_nonrating_hlr" }
      it "creates 5 messages" do
        expect(subject.flatten.count).to eq(5)
      end
    end

    context "when the issue is identified and does not contain an associated decision issue" do
      let(:issue_type) { "nonrating_hlr" }
      it "creates 6 messages" do
        expect(subject.flatten.count).to eq(6)
      end
    end
  end

  describe "#create_valid_and_eligible_nonrating_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_valid_and_eligible_nonrating_messages, issue_type, code) }
    let(:code) { sc_nonrating_ep_code }

    context "when the issue is unidentified" do
      let(:issue_type) { "nonrating_hlr_unidentified" }

      it "returns 6 messages" do
        expect(subject.flatten.count).to eq(6)
      end
    end

    context "when the issue is identified" do
      context "when the issue has an associated decision issue" do
        let(:issue_type) { "decision_issue_prior_nonrating_hlr" }

        it "returns 8 messages" do
          expect(subject.flatten.count).to eq(8)
        end
      end

      context "when the issue does ont have an associated decision issue" do
        let(:issue_type) { "nonrating_hlr" }

        it "returns 44 messages" do
          expect(subject.flatten.count).to eq(44)
        end
      end
    end
  end

  describe "#create_eligible_with_two_issues(issue_type, code)" do
    subject { decision_review_created_events.send(:create_eligible_with_two_issues, issue_type, code) }

    it "returns a message with 2 issues in the decision_review_issues array" do
      expect(subject.first.decision_review_issues.count).to eq(2)
    end
  end

  describe "#create_contested_with_additional_issue(issue_type, code)" do
    subject { decision_review_created_events.send(:create_contested_with_additional_issue, issue_type, code) }
    let(:decision_review_issues) { subject.first.decision_review_issues }

    it "returns a message with 2 issues in the decision_review_issues array" do
      expect(subject.first.decision_review_issues.count).to eq(2)
    end

    it "one of the decision review issues has eligibility_result 'CONTESTED'" do
      expect(decision_review_issues.count { |issue| issue.eligibility_result == "CONTESTED" }).to eq(1)
    end

    it "one of the decision review issues has eligibility_result that is NOT 'CONTESTED'" do
      expect(decision_review_issues.count { |issue| issue.eligibility_result != "CONTESTED" }).to eq(1)
    end
  end

  describe "#create_decision_type_messages(issue_type, code)" do
    subject { decision_review_created_events.send(:create_decision_type_messages, issue_type, code) }
    let(:original_dri_prior_decision_type) { decision_review_created.decision_review_issues.first.prior_decision_type }
    let(:original_dri_prior_decision_text) { decision_review_created.decision_review_issues.first.prior_decision_text }

    it "creates a message for each prior decision type in the NONRATING_DECISION_TYPES array" do
      expect(subject.count).to eq(34)
    end

    it "changes each message's prior_decision_type to include the decision type being mapped over" do
      expect(subject.all? { |drc| drc.decision_review_issues.first.prior_decision_type })
        .not_to eq(original_dri_prior_decision_type)
    end

    it "changes each message's prior_decision_text to include the decision text being mapped over" do
      expect(subject.all? { |drc| drc.decision_review_issues.first.prior_decision_text })
        .not_to eq(original_dri_prior_decision_text)
    end
  end

  describe "#change_issue_decision_type_and_decision_text(drc, decision_type)" do
    subject { decision_review_created_events.send(:change_issue_decision_type_and_decision_text, drc, decision_type) }
    let(:drc) { decision_review_created }
    let(:decision_type) { "Accrued" }
    let(:all_decision_review_issues) { subject.decision_review_issues.all? }

    it "changes the decision_review_issues to have a prior_decision_type matching the decision type passed in" do
      expect(all_decision_review_issues { |issue| issue.prior_decision_type == decision_type }).to eq true
    end

    it "changes the decision_review_issues to have a prior_decision_text that includes the decision type passed in" do
      expect(all_decision_review_issues { |issue| issue.prior_decision_text.include?(decision_type) }).to eq true
    end
  end

  describe "#randomize_claim_id(drc)" do
    subject { decision_review_created_events.send(:randomize_claim_id, drc) }
    let(:drc) { decision_review_created }

    it "randomizes the message's claim_id" do
      expect(drc.claim_id).not_to eq(subject)
    end
  end

  describe "#store_veteran_in_cache(drc)" do
    subject { decision_review_created_events.send(:store_veteran_in_cache, drc) }
    let(:drc) { decision_review_created }

    before do
      subject
    end

    it "stores a veteran record in the cache using the drc's file_number" do
      expect(Fakes::VeteranStore.new.all_veteran_file_numbers.include?(drc.file_number)).to eq true
    end
  end

  describe "#hlr_compensation_rating_ep_codes" do
    subject { decision_review_created_events.send(:hlr_compensation_rating_ep_codes) }
    it "returns all higher level review compensation rating ep codes" do
      expect(subject).to eq(ep_codes[:higher_level_review][:compensation][:rating])
    end
  end

  describe "#hlr_compensation_nonrating_ep_codes" do
    subject { decision_review_created_events.send(:hlr_compensation_nonrating_ep_codes) }
    it "returns all higher level review compensation nonrating ep codes" do
      expect(subject).to eq(ep_codes[:higher_level_review][:compensation][:nonrating])
    end
  end

  describe "#hlr_pension_rating_ep_codes" do
    subject { decision_review_created_events.send(:hlr_pension_rating_ep_codes) }
    it "returns all higher level review pension rating ep codes" do
      expect(subject).to eq(ep_codes[:higher_level_review][:pension][:rating])
    end
  end

  describe "#hlr_pension_nonrating_ep_codes" do
    subject { decision_review_created_events.send(:hlr_pension_nonrating_ep_codes) }
    it "returns all higher level review pension nonrating ep codes" do
      expect(subject).to eq(ep_codes[:higher_level_review][:pension][:nonrating])
    end
  end

  describe "#sc_compensation_nonrating_ep_codes" do
    subject { decision_review_created_events.send(:sc_compensation_nonrating_ep_codes) }
    it "returns all supplemental claim compensation rating ep codes" do
      expect(subject).to eq(ep_codes[:supplemental_claim][:compensation][:nonrating])
    end
  end

  describe "#sc_compensation_nonrating_ep_codes" do
    subject { decision_review_created_events.send(:sc_compensation_nonrating_ep_codes) }
    it "returns all supplemental claim compensation nonrating ep codes" do
      expect(subject).to eq(ep_codes[:supplemental_claim][:compensation][:nonrating])
    end
  end

  describe "#sc_pension_rating_ep_codes" do
    subject { decision_review_created_events.send(:sc_pension_rating_ep_codes) }
    it "returns all supplemental claim pension rating ep codes" do
      expect(subject).to eq(ep_codes[:supplemental_claim][:pension][:rating])
    end
  end

  describe "#sc_pension_nonrating_ep_codes" do
    subject { decision_review_created_events.send(:sc_pension_nonrating_ep_codes) }
    it "returns all supplemental claim pension nonrating ep codes" do
      expect(subject).to eq(ep_codes[:supplemental_claim][:pension][:nonrating])
    end
  end

  describe "#sc_rating_ep_codes" do
    subject { sc_rating_ep_codes }
    let(:sc_compensation_rating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:rating] }
    let(:sc_pension_rating_ep_codes) { ep_codes[:supplemental_claim][:pension][:rating] }
    it "returns an array of supplemental claim compensation and pension rating ep codes" do
      expect(subject).to eq(sc_compensation_rating_ep_codes + sc_pension_rating_ep_codes)
    end
  end

  describe "#hlr_rating_ep_codes" do
    subject { hlr_rating_ep_codes }
    let(:hlr_compensation_rating_ep_codes) { ep_codes[:higher_level_review][:compensation][:rating] }
    let(:hlr_pension_rating_ep_codes) { ep_codes[:higher_level_review][:pension][:rating] }
    it "returns an array of higher level review compensation and pension rating ep codes" do
      expect(subject).to eq(hlr_compensation_rating_ep_codes + hlr_pension_rating_ep_codes)
    end
  end

  describe "#rating_ep_codes" do
    subject { rating_ep_codes }
    let(:hlr_compensation_rating_ep_codes) { ep_codes[:higher_level_review][:compensation][:rating] }
    let(:hlr_pension_rating_ep_codes) { ep_codes[:higher_level_review][:pension][:rating] }
    let(:sc_compensation_rating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:rating] }
    let(:sc_pension_rating_ep_codes) { ep_codes[:supplemental_claim][:pension][:rating] }

    let(:hlr_rating_ep_codes) { hlr_compensation_rating_ep_codes + hlr_pension_rating_ep_codes }
    let(:sc_rating_ep_codes) { sc_compensation_rating_ep_codes + sc_pension_rating_ep_codes }
    it "returns an array of higher level review and supplemental claim compensation and pension rating ep codes" do
      expect(subject).to eq(sc_rating_ep_codes + hlr_rating_ep_codes)
    end
  end

  describe "#sc_nonrating_ep_codes" do
    subject { sc_nonrating_ep_codes }

    let(:sc_compensation_nonrating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:nonrating] }
    let(:sc_pension_nonrating_ep_codes) { ep_codes[:supplemental_claim][:pension][:nonrating] }

    it "returns an array of supplemental claim compensation and pension nonrating ep codes" do
      expect(subject).to eq(sc_compensation_nonrating_ep_codes + sc_pension_nonrating_ep_codes)
    end
  end

  describe "#hlr_nonrating_ep_codes" do
    subject { hlr_nonrating_ep_codes }

    let(:hlr_compensation_nonrating_ep_codes) { ep_codes[:higher_level_review][:compensation][:nonrating] }
    let(:hlr_pension_nonrating_ep_codes) { ep_codes[:higher_level_review][:pension][:nonrating] }

    it "returns an array ofhigher level review compensation and pension nonrating ep codes" do
      expect(subject).to eq(hlr_compensation_nonrating_ep_codes + hlr_pension_nonrating_ep_codes)
    end
  end

  describe "#nonrating_ep_codes" do
    subject { nonrating_ep_codes }

    let(:hlr_compensation_nonrating_ep_codes) { ep_codes[:higher_level_review][:compensation][:nonrating] }
    let(:hlr_pension_nonrating_ep_codes) { ep_codes[:higher_level_review][:pension][:nonrating] }
    let(:sc_compensation_nonrating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:nonrating] }
    let(:sc_pension_nonrating_ep_codes) { ep_codes[:supplemental_claim][:pension][:nonrating] }

    let(:hlr_nonrating_ep_codes) { hlr_compensation_nonrating_ep_codes + hlr_pension_nonrating_ep_codes }
    let(:sc_nonrating_ep_codes) { sc_compensation_nonrating_ep_codes + sc_pension_nonrating_ep_codes }
    it "returns an array of higher level review and supplemental claim compensation and pension nonrating ep codes" do
      expect(subject).to eq(sc_nonrating_ep_codes + hlr_nonrating_ep_codes)
    end
  end

  describe "#sc_ep_codes" do
    subject { decision_review_created_events.send(:sc_ep_codes) }

    let(:sc_compensation_rating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:rating] }
    let(:sc_pension_rating_ep_codes) { ep_codes[:supplemental_claim][:pension][:rating] }
    let(:sc_compensation_nonrating_ep_codes) { ep_codes[:supplemental_claim][:compensation][:nonrating] }
    let(:sc_pension_nonrating_ep_codes) { ep_codes[:supplemental_claim][:pension][:nonrating] }

    let(:sc_ep_codes) do
      sc_compensation_rating_ep_codes + sc_pension_rating_ep_codes +
        sc_compensation_nonrating_ep_codes + sc_pension_nonrating_ep_codes
    end

    it "returns an array of all supplemental claim ep codes" do
      expect(subject).to eq(sc_ep_codes)
    end
  end

  describe "#convert_and_format_message(message)" do
    subject { decision_review_created_events.send(:convert_and_format_message, message) }
    let(:message) { decision_review_created }
    let(:decision_review_issues) { message.decision_review_issues }
    let(:converted_and_formatted_decision_review_issues) do
      subject["decisionReviewIssues"]
    end

    let(:not_converted_dri_values) do
      decision_review_issues.map do |not_converted_issue|
        {
          contention_id: not_converted_issue.contention_id,
          prior_rating_decision_id: not_converted_issue.prior_rating_decision_id,
          prior_decision_rating_sn:
            not_converted_issue.prior_decision_rating_sn,
          prior_non_rating_id: not_converted_issue.prior_non_rating_decision_id,
          prior_caseflow_decision_issue_id: not_converted_issue.prior_caseflow_decision_issue_id,
          associated_caseflow_request_issue_id: not_converted_issue.associated_caseflow_request_issue_id,
          legacy_appeal_issue_id: not_converted_issue.legacy_appeal_issue_id
        }
      end
    end

    let(:converted_dri_values) do
      converted_and_formatted_decision_review_issues.map do |converted_issue|
        {
          contention_id: converted_issue["contentionId"],
          prior_rating_decision_id: converted_issue["priorRatingDecisionId"],
          prior_decision_rating_sn:
            converted_issue["priorDecisionRatingSn"],
          prior_non_rating_id: converted_issue["priorNonRatingDecisionId"],
          prior_caseflow_decision_issue_id: converted_issue["associatedCaseflowDecisionId"],
          associated_caseflow_request_issue_id: converted_issue["associatedCaseflowRequestIssueId"],
          legacy_appeal_issue_id: converted_issue["legacyAppealIssueId"]
        }
      end
    end

    let(:camelized_message) do
      hash = decision_review_created_events.send(:convert_message_to_hash, message)
      hash.deep_transform_keys! { |key| key.camelize(:lower) }
    end

    let(:camelized_message_keys) do
      message = camelized_message
      message.keys
    end

    context "when the message is a supplemental claim" do
      let(:message) { build(:decision_review_created, :eligible_nonrating_hlr) }

      before do
        message.ep_code = sc_nonrating_ep_code
      end

      it "changes the message decision_review_type from 'HIGHER_LEVEL_REVIEW' to 'SUPPLEMENTAL_CLAIM" do
        expect(subject["decisionReviewType"]).to eq("SUPPLEMENTAL_CLAIM")
      end
    end

    it "converts dates and timestamps from a string to an integer" do
      expect(subject["claimReceivedDate"].class).to eq(Integer)
      expect(subject["intakeCreationTime"].class).to eq(Integer)
      expect(subject["claimCreationTime"].class).to eq(Integer)

      converted_and_formatted_decision_review_issues.each do |issue|
        expect(issue["priorDecisionNotificationDate"].class).to eq(Integer)
      end
    end

    it "randomizes identifiers" do
      expect(not_converted_dri_values).not_to eq(converted_dri_values)
    end

    it "camelizes keys" do
      expect(subject.keys).to eq(camelized_message_keys)
    end
  end

  describe "#convert_dates_and_timestamps_to_int(message)" do
    subject { decision_review_created_events.send(:convert_dates_and_timestamps_to_int, message) }
    let(:message) { decision_review_created }

    it "converts dates and timestamps from a string to an integer" do
      expect(subject.claim_received_date.class).to eq(Integer)
      expect(subject.intake_creation_time.class).to eq(Integer)
      expect(subject.claim_creation_time.class).to eq(Integer)

      subject.decision_review_issues.each do |issue|
        expect(issue.prior_decision_date.class).to eq(Integer)
      end
    end
  end

  describe "#convert_decision_review_created_attrs(message)" do
    subject { decision_review_created_events.send(:convert_decision_review_created_attrs, message) }
    let(:message) { decision_review_created }

    it "converts drc dates and timestamps from a string to an integer" do
      expect(subject.claim_received_date.class).to eq(Integer)
      expect(subject.intake_creation_time.class).to eq(Integer)
      expect(subject.claim_creation_time.class).to eq(Integer)
    end
  end

  describe "#convert_drc_dates(message)" do
    subject { decision_review_created_events.send(:convert_drc_dates, message) }
    let(:message) { decision_review_created }

    it "converts drc dates a string to an integer" do
      expect(subject.claim_received_date.class).to eq(Integer)
    end
  end

  describe "#convert_drc_timestamps(message)" do
    subject { decision_review_created_events.send(:convert_drc_timestamps, message) }
    let(:message) { decision_review_created }

    it "converts drc timestamps from a string to an integer" do
      expect(subject.intake_creation_time.class).to eq(Integer)
      expect(subject.claim_creation_time.class).to eq(Integer)
    end
  end

  describe "#convert_value_to_date_logical_type(array_of_keys_with_date_value, object)" do
    subject do
      decision_review_created_events.send(:convert_value_to_date_logical_type, array_of_keys_with_date_value, message)
    end

    let(:message) { decision_review_created }
    let(:array_of_keys_with_date_value) { ["claim_received_date"] }

    it "converts the date from a string to an int" do
      subject
      expect(message.claim_received_date.class).to eq(Integer)
    end
  end

  describe "#convert_value_to_timestamp_ms(array_of_keys_with_timestamp_value, message)" do
    subject do
      decision_review_created_events.send(:convert_value_to_timestamp_ms, array_of_keys_with_timestamp_value, message)
    end

    let(:message) { decision_review_created }
    let(:array_of_keys_with_timestamp_value) { %w[intake_creation_time claim_creation_time] }

    it "converts the date from a string to an int" do
      subject
      expect(message.intake_creation_time.class).to eq(Integer)
      expect(message.claim_creation_time.class).to eq(Integer)
    end
  end

  describe "#convert_decision_review_issue_attrs(issue)" do
    subject { decision_review_created_events.send(:convert_decision_review_issue_attrs, issue) }

    let(:issue) { decision_review_created.decision_review_issues.first }

    it "converts string dates to an integer" do
      subject
      expect(issue.prior_decision_notification_date.class).to eq(Integer)
    end
  end

  describe "#convert_to_date_logical_type(key, object)" do
    subject { decision_review_created_events.send(:convert_to_date_logical_type, key, object) }
    let(:object) { decision_review_created }
    let(:key) { "claim_received_date" }

    context "when the key's value is nil" do
      before do
        object.claim_received_date = nil
      end

      it "leaves the value nil" do
        subject
        expect(object.claim_received_date).to eq nil
      end
    end

    context "when the key's value is not nil" do
      it "sets the object's key to the new value converted to an integer" do
        subject
        expect(object.claim_received_date.class).to eq(Integer)
      end
    end
  end

  describe "#date_string_converted_to_logical_type(key, object)" do
    subject { decision_review_created_events.send(:date_string_converted_to_logical_type, key, object) }
    let(:object) { decision_review_created }
    let(:key) { "claim_received_date" }

    it "converts the value to date logical type int" do
      expect(subject.class).to eq(Integer)
    end
  end

  describe "#convert_to_timestamp_ms(key, object)" do
    subject { decision_review_created_events.send(:convert_to_timestamp_ms, key, object) }
    let(:object) { decision_review_created }
    let(:key) { "intake_creation_time" }

    context "when the key's value is nil" do
      before do
        object.intake_creation_time = nil
      end

      it "leaves the value nil" do
        subject
        expect(object.intake_creation_time).to eq nil
      end
    end

    context "when the key's value is not nil" do
      it "sets the object's key to the new value converted to an integer" do
        subject
        expect(object.intake_creation_time.class).to eq(Integer)
      end
    end
  end

  describe "#set_value(key, object, converted_value)" do
    subject { decision_review_created_events.send(:set_value, key, object, converted_value) }
    let(:object) { decision_review_created }
    let(:key) { "claim_received_date" }
    let(:converted_value) do
      decision_review_created_events.send(:date_string_converted_to_logical_type, key, object)
    end

    it "sets the object's key to the given value" do
      expect(object.claim_received_date).to eq("2023-08-25")
      subject
      expect(object.claim_received_date).to eq(converted_value)
    end
  end

  describe "#timestamp_string_converted_to_timestamp_ms(key, object)" do
    subject { decision_review_created_events.send(:timestamp_string_converted_to_timestamp_ms, key, object) }
    let(:object) { decision_review_created }
    let(:key) { "claim_creation_time" }

    it "converts the value to date logical type int" do
      expect(subject.class).to eq(Integer)
    end
  end

  describe "#change_veteran_bis_response" do
    subject { decision_review_created_events.send(:change_veteran_bis_response) }
    let(:new_bis_record) { { ptcpnt_id: nil } }
    let(:file_number) { [decision_review_created.file_number] }

    before do
      Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
      decision_review_created_events
        .instance_variable_set(:@file_numbers_to_remove_from_cache, file_number)
    end

    it "restores the file number to the cache with new veteran_bis_record" do
      subject
      expect(Fakes::BISService.new.fetch_veteran_info(file_number)).to eq(new_bis_record)
    end
  end

  describe "#randomize_identifiers(message)" do
    subject { decision_review_created_events.send(:randomize_identifiers, message) }
    let(:message) { decision_review_created }
    let(:decision_review_issues) { message.decision_review_issues }
    let(:converted_decision_review_issues) do
      subject
    end

    let(:not_converted_dri_values) do
      decision_review_issues.map do |not_converted_issue|
        {
          contention_id: not_converted_issue.contention_id
        }
      end
    end

    let(:converted_dri_values) do
      converted_decision_review_issues.map do |converted_issue|
        {
          contention_id: converted_issue.contention_id
        }
      end
    end

    it "randomizes certain decision review issue identifiers" do
      expect(not_converted_dri_values).not_to eq(converted_dri_values)
    end
  end

  describe "#randomize_decision_review_issue_identifiers(issue)" do
    subject { decision_review_created_events.send(:randomize_decision_review_issue_identifiers, issue) }
    let(:issue) { decision_review_created.decision_review_issues.first }

    before do
      issue.contention_id = 1
      subject
    end

    it "randomizes specific keys for an individual decision review issue" do
      expect(issue.contention_id).not_to eq(1)
    end
  end

  describe "#change_supp_decision_review_type_from_hlr_to_sc(message)" do
    subject { decision_review_created_events.send(:change_supp_decision_review_type_from_hlr_to_sc, message) }
    let(:message) { decision_review_created }

    context "when the message is a supplemental claim" do
      before do
        message.ep_code = sc_rating_ep_code
      end

      it "changes the decision_review_type from 'HIGHER_LEVEL_REVIEW' to 'SUPPLEMENTAL_CLAIM'" do
        expect(message.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
        subject
        expect(message.decision_review_type).to eq("SUPPLEMENTAL_CLAIM")
      end
    end

    context "when the message is a higher level review" do
      it "does not change the decision_review_type from 'HIGHER_LEVEL_REVIEW' to 'SUPPLEMENTAL_CLAIM'" do
        expect(message.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
        subject
        expect(message.decision_review_type).to eq("HIGHER_LEVEL_REVIEW")
      end
    end
  end

  describe "#change_decision_review_type_to_sc(message)" do
    subject { decision_review_created_events.send(:change_decision_review_type_to_sc, message) }
    let(:message) { decision_review_created }

    it "changes the decision_review_type to 'SUPPLEMENTAL_CLAIM'" do
      subject
      expect(message.decision_review_type).to eq("SUPPLEMENTAL_CLAIM")
    end
  end

  describe "#convert_file_number_to_string(message)" do
    subject { decision_review_created_events.send(:convert_file_number_to_string, message) }
    let(:message) { decision_review_created }

    before do
      message.file_number = 1234
    end

    it "converts the file number to a string" do
      subject
      expect(message.file_number).to eq("1234")
    end
  end

  describe "#unidentified?(issue_type)" do
    subject { decision_review_created_events.send(:unidentified?, issue_type) }

    context "when the issue_type includes 'unidentified'" do
      let(:issue_type) { "rating_hlr_unidentified" }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue_type does not include 'unidentified'" do
      let(:issue_type) { "rating_hlr" }

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#rating_decision?(issue_type)" do
    subject { decision_review_created_events.send(:rating_decision?, issue_type) }

    context "when the issue_type includes 'rating_decision'" do
      let(:issue_type) { "rating_decision_hlr" }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue_type does not include 'rating_decision'" do
      let(:issue_type) { "rating_hlr" }

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#associated_decision_issue?(issue_type)" do
    subject { decision_review_created_events.send(:associated_decision_issue?, issue_type) }

    context "when the issue_type includes 'decision_issue_prior'" do
      let(:issue_type) { "decision_issue_prior_rating_hlr" }

      it "returns true" do
        expect(subject).to eq true
      end
    end

    context "when the issue_type does not include 'decision_issue_prior'" do
      let(:issue_type) { "rating_hlr" }

      it "returns false" do
        expect(subject).to eq false
      end
    end
  end

  describe "#randomize_value(key, object)" do
    subject { decision_review_created_events.send(:randomize_value, key, object) }
    let(:object) { decision_review_created }
    let(:key) { "file_number" }
    let(:not_converted_file_number) { object.file_number }
    let(:converted_file_number) do
      subject
      object.file_number
    end

    context "when the value for the given key is nil" do
      before do
        object.file_number = nil
      end

      it "keeps the value nil" do
        subject
        expect(object.file_number).to eq nil
      end
    end

    context "when the value for the given key is not nil" do
      it "sets the value to a unique six digit integer" do
        expect(not_converted_file_number).not_to eq(converted_file_number)
        expect(converted_file_number.to_s.length).to eq(6)
      end
    end
  end

  describe "#camelize_keys(message)" do
    subject { decision_review_created_events.send(:camelize_keys, message) }
    let(:message) { decision_review_created }
    let(:hash_message) do
      decision_review_created_events.send(:convert_message_to_hash, message)
    end

    let(:camelcase_hash) do
      hash_message.deep_transform_keys! { |key| key.camelize(:lower) }
    end

    it "converts the message to a hash and converts the keys from snake case to lower camel case" do
      expect(subject).to eq(camelcase_hash)
    end
  end

  describe "#convert_message_to_hash(message)" do
    subject { decision_review_created_events.send(:convert_message_to_hash, message) }
    let(:message) { decision_review_created }

    before do
      expect(message).to be_an_instance_of(Transformers::DecisionReviewCreated)
      expect(message).not_to be_a(Hash)
    end

    it "converts the message from an active record instance into a ruby hash" do
      expect(subject).to be_a(Hash)
    end
  end

  # WIP
  # rubocop:disable Layout/LineLength
  describe "#encode_message(message)" do
    subject { decision_review_created_events.send(:encode_message, message) }
    let(:avro_service) { double(AvroService.new) }
    let(:schema_name) { "VBMS_CEST_UAT_DECISION_REVIEW_INTAKE" }
    let(:message) { decision_review_created_events.send(:convert_and_format_message, decision_review_created) }
    let(:sample_encoded_message) { "Obj\u0001\u0004\u0014avro.codec\bnull\u0016avro.schema\x9E\u0005{\"type\":\"record\",\"name\":\"person\",\"doc\":\"just a person\",\"fields\":[{\"name\":\"full_name\",\"type\":\"string\",\"doc\":\"full name of person\"},{\"name\":\"age\",\"type\":\"int\",\"doc\":\"age of person\"},{\"name\":\"computer\",\"type\":{\"type\":\"record\",\"name\":\"computer\",\"doc\":\"my work computer\",\"fields\":[{\"name\":\"brand\",\"type\":\"string\",\"doc\":\"name of brand\"}]}}]}\u0000\xE7z\\\x9C\xE4CJݦ\u0003\xAB[+״\xB0\u0002\u0014\bJohnd\u0006mac\xE7z\\\x9C\xE4CJݦ\u0003\xAB[+״\xB0" }

    before do
      allow(AvroService).to receive(:new).and_return(avro_service)
      allow(avro_service.instance_variable_get(:@avro)).to receive(:encode)
        .with(message, subject: schema_name, version: ENV["SCHEMA_VERSION"], validate: true)
        .and_return(sample_encoded_message)
    end

    it "encodes the message and returns the encoded message" do
      expect(avro_service).to receive(:encode)
        .with(message, schema_name)
      subject
    end
  end
  # rubocop:enable Layout/LineLength

  describe "#publish_message(message)" do
    subject { decision_review_created_events.send(:publish_message, message) }
    let(:prepared_message) { decision_review_created_events.send(:convert_and_format_message, decision_review_created) }
    let(:message) { decision_review_created_events.send(:encode_message, prepared_message) }

    before do
      allow(Karafka.producer).to receive(:produce_sync)
    end

    it "publishes 1 message to the DecisionReviewCreated topic" do
      subject
      expect(Karafka.producer).to have_received(:produce_sync).once do |args|
        expect(args[:topic]).to eq("VBMS_CEST_UAT_DECISION_REVIEW_INTAKE")
      end
    end
  end
end
