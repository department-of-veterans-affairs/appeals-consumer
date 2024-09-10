# frozen_string_literal: true

describe KafkaMessageGenerators::DecisionReviewEvents do
  let(:decision_review_updated_events) { described_class.new("decision_review_updated") }
  let(:decision_review_updated) { build(:decision_review_updated) }
  let(:veteran_bis_record) do
    {
      file_number: decision_review_updated.file_number,
      ptcpnt_id: decision_review_updated.veteran_participant_id,
      sex: "M",
      first_name: decision_review_updated.veteran_first_name,
      middle_name: "Russell",
      last_name: decision_review_updated.veteran_last_name,
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
  let(:decision_review_issues_created) { "decisionReviewIssuesCreated" }
  let(:decision_review_issues_updated) { "decisionReviewIssuesUpdated" }
  let(:decision_review_issues_removed) { "decisionReviewIssuesRemoved" }
  let(:decision_review_issues_withdrawn) { "decisionReviewIssuesWithdrawn" }
  let(:decision_review_issues_not_changed) { "decisionReviewIssuesNotChanged" }

  describe "#initialize" do
    subject { decision_review_updated_events }
    before do
      Fakes::VeteranStore.new.store_veteran_record(decision_review_updated.file_number, veteran_bis_record)
    end

    it "clears the cache" do
      subject
      expect(Fakes::VeteranStore.new.all_veteran_file_numbers).to be_empty
    end

    it "creates an array instance variable called file_numbers_to_remove_from_cache" do
      expect(subject.instance_variable_get(:@file_numbers_to_remove_from_cache)).to eq([])
    end

    it "creates an instance variable called decision_review_event_type" do
      expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
    end
  end

  describe "#publish_messages" do
    subject { decision_review_updated_events.publish_messages! }
    before do
      allow(Karafka.producer).to receive(:produce_sync)
    end

    it "publishes 5931 messages to the DecisionReviewUpdated topic" do
      subject
      expect(Karafka.producer).to have_received(:produce_sync).exactly(5931).times do |args|
        expect(args[:topic]).to eq(ENV["DECISION_REVIEW_UPDATED_TOPIC"])
      end
    end
  end

  describe "#ensure_messages_contain_bis_rating_profile(rating_messages)" do
    subject { decision_review_updated_events }
    let(:rating_messages) { [rating_message_1, rating_message_2] }
    let(:rating_message_1) { build(:decision_review_updated, :eligible_rating_hlr_time_override) }
    let(:rating_message_2) { build(:decision_review_updated, :eligible_rating_hlr_time_override) }
    before do
      allow(subject).to receive(:store_issue_bis_rating_profile_without_ramp_id)
      allow(subject).to receive(:should_skip_creating_bis_rating_profile?).with(rating_message_1).and_return(false)
      allow(subject).to receive(:should_skip_creating_bis_rating_profile?).with(rating_message_2).and_return(false)
    end
    it "doesnt skip and stores issue bis_rating_profile_without_ramp_id" do
      decision_review_updated_events.send(:ensure_messages_contain_bis_rating_profile, rating_messages)
      expect(subject).to have_received(:store_issue_bis_rating_profile_without_ramp_id).with(rating_message_1)
      expect(subject).to have_received(:store_issue_bis_rating_profile_without_ramp_id).with(rating_message_2)
      issue = rating_message_1.decision_review_issues_created
      bis_record = decision_review_updated_events.send(:bis_rating_profile_without_ramp, issue[0], rating_message_1)
      expect(decision_review_updated_events.send(:store_bis_rating_profiles, rating_message_1, bis_record)).to eq("OK")
    end
  end

  describe "#create_dre_message(trait, ep_code)" do
    subject { decision_review_updated_events }
    let(:claimant_participant_id) { "claimantParticipantId" }
    let(:contention_action) { "contentionAction" }
    let(:contention_id) { "contentionId" }
    let(:decision_review_type) { "decisionReviewType" }
    let(:ep_code_category) { "epCodeCategory" }
    let(:informal_conference_requested) { "informalConferenceRequested" }
    let(:legacy_appeal_id) { "legacyAppealId" }
    let(:prior_non_rating_decision_id) { "priorNonRatingDecisionId" }
    let(:prior_decision_rating_profile_date) { "priorDecisionRatingProfileDate" }
    let(:prior_decision_text) { "priorDecisionText" }
    let(:reason_for_contention_action) { "reasonForContentionAction" }
    let(:same_station_review_requested) { "sameStationReviewRequested" }
    let(:unidentified) { "unidentified" }
    let(:veteran_participant_id) { "veteranParticipantId" }

    # Test for the following scnearios in message_payload
    # veteran_claimant
    ## rating
    ### eligible
    ### higher_level_rating
    context "creates Decision Review Updated eligible_rating_hlr_veteran_claimant message" do
      let(:trait) { "eligible_rating_hlr_veteran_claimant" }
      let(:ep_code) { "030HLRR" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("rating")
        expect(fm_issues_created[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_created[contention_action]).to eq("NONE")
        expect(fm_issues_created[contention_id]).to eq(nil)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    ### supplemental_claims
    context "creates DecisionReviewUpdated eligible_rating_decision_hlr_legacy SupplementalClaim Message" do
      let(:trait) { "eligible_rating_decision_hlr_legacy" }
      let(:ep_code) { "040SCR" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: UPDATE_CONTENTION & ELIGIBLE_TO_INELIGIBLE" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("rating")
        expect(fm_issues_created[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("ELIGIBLE_TO_INELIGIBLE")
        expect(fm_issues_updated[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # Same Station Requested
    context "creates DecisionReviewUpdated ineligible_rating_decision_hlr_with_contention_id  message" do
      let(:trait) { "ineligible_rating_decision_hlr_with_contention_id" }
      let(:ep_code) { "030HLRRPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Same Station Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("rating")
        expect(fm_issues_created[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(formatted_message[same_station_review_requested]).to eq(true)
        expect(fm_issues_updated[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # informal conference requested
    context "creates DecisionReviewUpdated eligible_decision_issue_prior_nonrating_sc_legacy message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr_legacy" }
      let(:ep_code) { "040SCRPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Informal Conference Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_created[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(fm_issues_updated[legacy_appeal_id]).to eq("LEGACYID")
        expect(formatted_message[informal_conference_requested]).to eq(true)
        expect(fm_issues_updated[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_removed[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_withdrawn[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_not_changed[legacy_appeal_id]).to eq("LEGACYID")
      end
    end

    ## non_rating
    ### eligible & ineligible
    #### higher_level_rating
    ##### decision_review_issues
    context "creates Decision Review Updated eligible_decision_issue_prior_nonrating_hlr_veteran_claimant message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr_veteran_claimant" }
      let(:ep_code) { "030HLRNR" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: UPDATE_CONTENTION & PRIOR_DECISION_TEXT_CHANGED" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_updated[prior_decision_text]).to eq("Service connection for tetnus denied (UPDATED)")
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    context "creates Decision Review Updated eligible_decision_issue_prior_nonrating_sc_legacy message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr_legacy" }
      let(:ep_code) { "040SCRPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Informal Conference Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_created[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(formatted_message[informal_conference_requested]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_removed[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_withdrawn[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_not_changed[legacy_appeal_id]).to eq("LEGACYID")
      end
    end

    context "creates Decision Review Updated eligible_nonrating_hlr_with_decision_source message" do
      let(:trait) { "eligible_nonrating_hlr_with_decision_source" }
      let(:ep_code) { "930AMAHDENCL" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Same Station Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(formatted_message[same_station_review_requested]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    context "creates DecisionReviewUpdated eligible_decision_issue_prior_nonrating_hlr_without_contention_id message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr_without_contention_id" }
      let(:ep_code) { "930AHCNRNPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: NONE & NO_CHANGES" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("NONE")
        expect(fm_issues_created[contention_id]).to eq(nil)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    #### supplemental_claims
    ##### decision_review_issues
    context "creates DecisionReviewUpdated ineligible_nonrating_sc_contested SupplementalClaim Message" do
      let(:trait) { "ineligible_nonrating_hlr_contested" }
      let(:ep_code) { "040ADONRPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: PRIOR_DECISION_TEXT_CHANGED & (UPDATED)" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_updated[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # Same Station Requested
    context "creates DecisionReviewUpdated :eligible_nonrating_sc_with_decision_source  message" do
      let(:trait) { "eligible_nonrating_hlr_with_decision_source" }
      let(:ep_code) { "930AMARNRC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Same Station Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).not_to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(formatted_message[same_station_review_requested]).to eq(true)
        expect(fm_issues_updated[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # informal Conference Requested
    context "creates Decision Review Updated eligible_decision_issue_prior_nonrating_sc_legacy message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr_legacy" }
      let(:ep_code) { "040HDENRPMC" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario:  SPECIAL_ISSUES_CHANGED & Informal Conference Requested" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[decision_review_type]).to eq("SUPPLEMENTAL_CLAIM")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_created[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_updated[reason_for_contention_action]).to eq("SPECIAL_ISSUES_CHANGED")
        expect(formatted_message[informal_conference_requested]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_removed[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_withdrawn[legacy_appeal_id]).to eq("LEGACYID")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_not_changed[legacy_appeal_id]).to eq("LEGACYID")
      end
    end

    # unidentified
    context "creates Decision Review Updated eligible_rating_hlr_unidentified_non_veteran_claimant message" do
      let(:trait) { "eligible_rating_hlr_unidentified_non_veteran_claimant" }
      let(:ep_code) { "930AMAHDER" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: unidentified" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).not_to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("rating")
        expect(fm_issues_created[prior_decision_rating_profile_date]).not_to be_nil
        expect(fm_issues_created[contention_action]).to eq("NONE")
        expect(fm_issues_created[contention_id]).to eq(nil)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NO_CHANGES")
        expect(fm_issues_updated[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("ELIGIBLE_TO_INELIGIBLE")
        expect(fm_issues_updated[unidentified]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # unidentified
    context "creates Decision Review Updated eligible_nonrating_hlr_unidentified_veteran_claimant message" do
      let(:trait) { "eligible_nonrating_hlr_unidentified_veteran_claimant" }
      let(:ep_code) { "930AMAHDER" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: unidentified" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[0][contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[0][contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[0][reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_updated[0][prior_decision_text]).to eq("Service connection for tetnus denied (UPDATED)")
        expect(fm_issues_updated[0][unidentified]).to eq(true)
        expect(fm_issues_updated[1][contention_action]).to eq("NONE")
        expect(fm_issues_updated[1][contention_id].to_s).to start_with("71")
        expect(fm_issues_updated[1][reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_updated[1][prior_decision_text]).to eq("Service connection for tetnus denied (UPDATED)")
        expect(fm_issues_updated[1][unidentified]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    # unidentified
    context "creates Decision Review Updated eligible_nonrating_hlr_unidentified_without_prior_decision_date message" do
      let(:trait) { "eligible_nonrating_hlr_unidentified_without_prior_decision_date" }
      let(:ep_code) { "930AMAHDER" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: unidentified" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).not_to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("PRIOR_DECISION_TEXT_CHANGED")
        expect(fm_issues_updated[prior_decision_text]).to eq("DIC: Service connection for tetnus denied (UPDATED)")
        expect(fm_issues_updated[unidentified]).to eq(true)
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end

    context "creates Decision Review Updated eligible_decision_issue_prior_nonrating_hlr message" do
      let(:trait) { "eligible_decision_issue_prior_nonrating_hlr" }
      let(:ep_code) { "930AMAHDERCL" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points for scenario: INELIGIBLE_REASON_CHANGED" do
        message = subject.send(:create_dre_message, trait, ep_code)
        formatted_message = subject.send(:convert_and_format_message, message)
        fm_issues_created = formatted_message[decision_review_issues_created][0]
        fm_issues_updated = formatted_message[decision_review_issues_updated][0]
        fm_issues_removed = formatted_message[decision_review_issues_removed][0]
        fm_issues_withdrawn = formatted_message[decision_review_issues_withdrawn][0]
        fm_issues_not_changed = formatted_message[decision_review_issues_not_changed][0]
        expect(subject.instance_variable_get(:@decision_review_event_type)).to eq("decision_review_updated")
        expect(formatted_message[veteran_participant_id]).not_to eq(formatted_message[claimant_participant_id])
        expect(formatted_message[decision_review_type]).to eq("HIGHER_LEVEL_REVIEW")
        expect(formatted_message[ep_code_category]).to eq("NON_RATING")
        expect(fm_issues_created[prior_decision_rating_profile_date]).to be_nil
        expect(fm_issues_created[contention_action]).to eq("ADD_CONTENTION")
        expect(fm_issues_created[contention_id]).to eq(720_000_000)
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEW_ELIGIBLE_ISSUE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("INELIGIBLE_REASON_CHANGED")
        expect(fm_issues_updated[prior_decision_text]).to eq("Service connection for tetnus denied")
        expect(fm_issues_removed[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_removed[contention_id]).to eq(710_000_001)
        expect(fm_issues_removed[reason_for_contention_action]).to eq("REMOVED_SELECTED")
        expect(fm_issues_withdrawn[contention_action]).to eq("DELETE_CONTENTION")
        expect(fm_issues_withdrawn[contention_id]).to eq(710_000_003)
        expect(fm_issues_withdrawn[reason_for_contention_action]).to eq("WITHDRAWN_SELECTED")
        expect(fm_issues_not_changed[contention_action]).to eq("NONE")
        expect(fm_issues_not_changed[contention_id]).to eq(710_000_000)
        expect(fm_issues_not_changed[reason_for_contention_action]).to eq("NO_CHANGES")
      end
    end
  end
end
