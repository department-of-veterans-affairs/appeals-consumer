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
  end

  describe "#publish_messages!" do
    subject { decision_review_updated_events.publish_messages! }
    it "#create_messages" do
      subject
    end
  end

  # test decision_review_updated?
  describe "#convert_drc_timestamp(message)" do
  end

  # test
  describe "#update_value(key, object)" do
  end

  describe "#convert_dates_and_timestamps_to_int(message)" do
  end

  describe "#create_drc_message(trait, ep_code)" do
    subject { decision_review_updated_events }
    let(:contention_action) { "contentionAction" }
    let(:contention_id) { "contentionId" }
    let(:decision_review_type) { "decisionReviewType" }
    let(:ep_code_category) { "epCodeCategory" }
    let(:reason_for_contention_action) { "reasonForContentionAction" }
    let(:prior_decision_rating_profile_date) { "priorDecisionRatingProfileDate" }
    let(:veteran_participant_id) { "veteranParticipantId" }
    let(:claimant_participant_id) { "claimantParticipantId" }

    # Test for the following scnearios in message_payload
    # veteran_claimant
    ## rating
    ### eligible & ineligible
    ### higher_level_rating
    context "creates eligible_rating_hlr_veteran_claimant message" do
      let(:trait) { "eligible_rating_hlr_veteran_claimant" }
      let(:ep_code) { "030HLRR" }
      let(:topic) { ENV["DECISION_REVIEW_UPDATED_TOPIC"] }
      it "correct data points" do
        message = subject.send(:create_drc_message, trait, ep_code)
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
        expect(fm_issues_created[reason_for_contention_action]).to eq("NEWLY_ELIGIBLE")
        expect(fm_issues_updated[contention_action]).to eq("UPDATE_CONTENTION")
        expect(fm_issues_updated[contention_id]).to eq(710_000_002)
        expect(fm_issues_updated[reason_for_contention_action]).to eq("NEWLY_ELIGIBLE")
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

  ### supplemental_claims
  #### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  ## non_rating
  ### eligible & ineligible
  #### higher_level_rating
  ##### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  #### supplemental_claims
  ##### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  # non_veteran_claimant
  ## rating
  ### eligible & ineligible
  ### higher_level_rating

  #### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  ### supplemental_claims
  #### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  ## non_rating
  ### eligible & ineligible
  #### higher_level_rating
  ##### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000

  #### supplemental_claims
  ##### decision_review_issues
  # _created
  # contention_action: "ADD_CONTENTION" reason_for_contention_action: "NEWLY_ELIGIBLE" contention_id starts with 720_000_000
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id: nil

  # _updated
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "PRIOR_DECISION_TEXT_CHANGED" contention_id starts with 710_000_000

  # informal_conference_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # same_station_review_requested: true
  # contention_action: "UPDATE_CONTENTION" reason_for_contention_action: "SPECIAL_ISSUES_CHANGED"   contention_id starts with 710_000_000

  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "ELIGIBLE_TO_INELIGIBLE" contention_id starts with 710_000_000

  # _removed
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "REMOVED_SELECTED" removed: true contention_id starts with 710_000_000

  # _withdrawn
  # contention_action: "DELETE_CONTENTION" reason_for_contention_action: "WITHDRAWN_SELECTED" withdrawn: true contention_id starts with 710_000_000

  #  _no_changes
  # contention_action: "NONE" reason_for_contention_action: "NO_CHANGES" contention_id starts with 710_000_000
end
