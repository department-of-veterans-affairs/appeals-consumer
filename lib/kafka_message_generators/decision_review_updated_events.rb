# frozen_string_literal: true

module KafkaMessageGenerators
  class DecisionReviewUpdatedEvents
    # all possible ep codes appeals-consumer could receive from vbms intake
    EP_CODES ||=KafkaMessageGenerators::Base.ep_codes

    # "DIC" is also a nonrating issue decision type but it isn't included in this last due
    # to it already being accounted for in the decision_review_created factory used throughout this class
    NONRATING_DECISION_TYPES ||=KafkaMessageGenerators::Base.non_rating_decision_types

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
      messages = create_messages
      puts "Finished creating messages!"

      puts "Started preparing and publishing #{messages.flatten.count} messages..."
      messages.flatten.each do |message|
        topic = ENV["DECISION_REVIEW_UPDATED_TOPIC"]
        formatted_message = convert_and_format_message(message)
        encoded_message = KafkaMessageGenerators::Base.encode_message(formatted_message, topic)
        KafkaMessageGenerators::Base.publish_message(encoded_message, topic)
      end
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
