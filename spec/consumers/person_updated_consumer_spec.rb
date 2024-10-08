# frozen_string_literal: true
# based off of the decion review example, edits needed based on schema.
describe PersonUpdatedConsumer do
    let(:consumer) { described_class.new }
    let(:message) { instance_double("Message", payload: payload, metadata: metadata) }
    ## !! let(:payload) { double("Payload", message: { "claim_id" => 123 }, writer_schema: writer_schema) }
    let(:metadata) { double("Metadata", offset: 555, partition: 5) }
    ## ?? let(:writer_schema) { double(fullname: "SchemaName") }
    let(:event_state) { "not_started" }
    let(:event_type) { "Events::PersonUpdatedEvent" }
    let(:decision_review_updated_extra_details) do
      {
        partition: metadata.partition,
        offset: metadata.offset,
        claim_id: payload.message["claim_id"],
        type: described_class::EVENT_TYPE
      }
    end



end