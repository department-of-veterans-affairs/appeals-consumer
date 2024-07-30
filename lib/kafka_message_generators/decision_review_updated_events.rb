# frozen_string_literal: true

module KafkaMessageGenerators
  class DecisionReviewUpdatedEvents
    # all possible ep codes appeals-consumer could receive from vbms intake
    EP_CODES ||=
      {
        higher_level_review: {
          compensation: {
            rating: %w[030HLRR 930AMAHRC 930AMAHDER 930AMAHCRLQE 930AMAHDERCL 930AMAHCRNQE 930AMAHDERCN],
            nonrating: %w[030HLRNR 930AMAHNRC 930AMAHDENR 930AHCNRLQE 930AMAHDENCL 930AHCNRNQE 930AMAHDENCN]
          },
          pension: {
            rating: %w[030HLRRPMC 930AMAHRCPMC 930AHDERPMC 930AHCRLQPMC 930AHDERLPMC 930AHCRNQPMC 930AHDERNPMC],
            nonrating: %w[030HLRNRPMC 930AHNRCPMC 930AHDENRPMC 930AHCNRLPMC 930AHDENLPMC 930AHCNRNPMC 930AHDENNPMC]
          }
        },
        supplemental_claim: {
          compensation: {
            rating: %w[040SCR 040HDER 040AMDAOR 930AMASRC 930AMARRC 930AMADOR 930AMASCRLQE
                       930AMARRCLQE 930AMASCRNQE 930AMARRCNQE 040SCRGTY],
            nonrating: %w[040SCNR 040HDENR 040AMADONR 930AMASNRC 930AMARNRC 930AMADONR
                          930ASCNRLQE 930ARNRCLQE 930ASCNRNQE 930ARNRCNQE]
          },
          pension: {
            rating: %w[040SCRPMC 040HDERPMC 040ADORPMC 930AMASRCPMC 930AMARRCPMC 930ASCRLQPMC
                       930ARRCLQPMC 930ASCRNQPMC 930ARRCNQPMC 930ADORPMC],
            nonrating: %w[040SCNRPMC 040HDENRPMC 040ADONRPMC 930ASNRCPMC 930ARNRCPMC 930ASCNRLPMC
                          930ARNRCLPMC 930ASCNRNPMC 930ARNRCNPMC 930ADONRPMC]
          }
        }
      }.freeze

    # "DIC" is also a nonrating issue decision type but it isn't included in this last due
    # to it already being accounted for in the decision_review_created factory used throughout this class
    NONRATING_DECISION_TYPES ||=
      [
        "Accrued",
        "Allotment",
        "Apportionment",
        "Attorney Fee",
        "Basic Eligibility",
        "Burial - Plot Allowance",
        "Burial - Transportation Allowance",
        "Burial - Service Connected",
        "Burial - Non Service Connected",
        "Burial - SC Burial and Transportation",
        "Burial - NSC Burial and Plot Allowance",
        "Burial - NSC Burial, Plot and Transportation",
        "Burial - Other",
        "Burial - No Burial Benefit Entitlement Due to Service",
        "Burial - State Plot Allowance",
        "Burial - Marker/Engraver Reimbursement",
        "Chapter 18",
        "Clothing Allowance",
        "Custody of Children",
        "DIC Spouse Status",
        "Dependency",
        "Disability Pay Adjustment",
        "Drill Pay Adjustment",
        "Election",
        "Expense",
        "Fraud",
        "Income",
        "Institutionalization Adjustment",
        "Medal of Honor",
        "Military Eligibility",
        "Net Worth",
        "Other Witholding Adjustment",
        "Retired Pay Adjustment",
        "Separation Pay Adjustment"
      ].freeze

    # clears the cache incase any records are currently stored
    # initializes variable that will hold file numbers to be removed from the cache
    # these file numbers will get a different bis response than the rest to test event audit notes and logging
    def initialize
      clear_cache
      @file_numbers_to_remove_from_cache = []
      @contention_id = 710_000_000
      @veteran_participant_id = "210000000"
      @claimant_participant_id = "950000000"
      @file_number = "310000000"
    end

    # creates all vbms intake scenarios for every ep code
    # including scenarios that would raise an error within appeals-consumer
    def publish_messages!
      puts "Started creating messages..."
      # messages = create_messages
      puts "Finished creating messages!"

      # puts "Started preparing and publishing #{messages.flatten.count} messages..."
      # messages.flatten.each do |message|
      #   formatted_message = convert_and_format_message(message)
      #   encoded_message = encode_message(formatted_message)
      #   publish_message(encoded_message)
      # end
      # puts "Finished publishing #{@published_messages_count} messages!"
    end

    private

    # incase any records are stored locally, clear the cache to prevent conflict
    def clear_cache
      BISService.clean!
    end

    # create messages based on rating/nonrating
    def create_messages
      rating = create_rating_messages
      nonrating = create_nonrating_messages

      rating + nonrating
    end
    
    # create the same nonrating scenarios for both hlr/supplemental and compesation/pension
    def create_nonrating_messages
      [create_nonrating_ep_code_messages(nonrating_ep_codes)]
    end

    # create the same rating scenarios for both hlr/supplemental and compesation/pension
    def create_rating_messages
      [create_rating_ep_code_messages(rating_ep_codes)]
    end

    # create messages for all types of rating issues
    def create_nonrating_issue_type_messages(code)
      [
        create_nonrating_issue_messages(code)
        # create_decision_issue_prior_nonrating_messages(code),
        # create_unidentified_nonrating_messages(code)
      ]
    end

    def hlr_compensation_rating_ep_codes
      EP_CODES[:higher_level_review][:compensation][:rating]
    end

    def hlr_compensation_nonrating_ep_codes
      EP_CODES[:higher_level_review][:compensation][:nonrating]
    end

    def hlr_pension_rating_ep_codes
      EP_CODES[:higher_level_review][:pension][:rating]
    end

    def hlr_pension_nonrating_ep_codes
      EP_CODES[:higher_level_review][:pension][:nonrating]
    end

    def sc_compensation_rating_ep_codes
      EP_CODES[:supplemental_claim][:compensation][:rating]
    end

    def sc_compensation_nonrating_ep_codes
      EP_CODES[:supplemental_claim][:compensation][:nonrating]
    end

    def sc_pension_rating_ep_codes
      EP_CODES[:supplemental_claim][:pension][:rating]
    end

    def sc_pension_nonrating_ep_codes
      EP_CODES[:supplemental_claim][:pension][:nonrating]
    end

    def sc_rating_ep_codes
      sc_compensation_rating_ep_codes + sc_pension_rating_ep_codes
    end

    def hlr_rating_ep_codes
      hlr_compensation_rating_ep_codes + hlr_pension_rating_ep_codes
    end

    def rating_ep_codes
      sc_rating_ep_codes + hlr_rating_ep_codes
    end

    def sc_nonrating_ep_codes
      sc_compensation_nonrating_ep_codes + sc_pension_nonrating_ep_codes
    end

    def hlr_nonrating_ep_codes
      hlr_compensation_nonrating_ep_codes + hlr_pension_nonrating_ep_codes
    end

    def nonrating_ep_codes
      sc_nonrating_ep_codes + hlr_nonrating_ep_codes
    end

    def sc_ep_codes
      sc_rating_ep_codes + sc_nonrating_ep_codes
    end
  end
end
