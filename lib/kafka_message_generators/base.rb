# frozen_string_literal: true

module KafkaMessageGenerators::Base
  class << self
    def camelize_keys(message)
      hash = convert_message_to_hash(message)
      hash.deep_transform_keys! { |key| key.camelize(:lower) }
    end

    def convert_message_to_hash(message)
      json = message.to_json
      hash = JSON.parse(json)
      hash.delete("event_id")
      hash
    end

    # encode message before publishing
    def encode_message(message, topic)
      AvroService.new.encode(message, topic)
    end

    # publish message to the DecisionReviewCreated topic
    def publish_message(encoded_message, topic)
      @published_messages_count ||= 0
      Karafka.producer.produce_sync(
        topic: topic,
        payload: encoded_message
      )
      @published_messages_count += 1
    end

    # all possible ep codes appeals-consumer could receive from vbms intake
    def ep_codes
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
    end

    def non_rating_decision_types
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
    end

  end
end
