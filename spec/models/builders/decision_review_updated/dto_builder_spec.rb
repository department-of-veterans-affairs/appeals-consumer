# frozen_string_literal: true

require "shared_context/decision_review_updated_context"

RSpec.describe Builders::DecisionReviewUpdated::DtoBuilder, type: :model do
  subject(:dto_builder) { described_class.new(decision_review_updated_event) }

  include_context "decision_review_updated_context"

  before do
    allow(Builders::DecisionReviewUpdated::ClaimReviewBuilder).to receive(:build).and_return("claim_review")
    allow(Builders::DecisionReviewUpdated::EndProductEstablishmentBuilder)
      .to receive(:build)
      .and_return("end_product_establishment")
    allow(Builders::DecisionReviewUpdated::AddedIssueCollectionBuilder).to receive(:build).and_return("added_issues")
    allow(Builders::DecisionReviewUpdated::UpdatedIssueCollectionBuilder)
      .to receive(:build)
      .and_return("updated_issues")
    allow(Builders::DecisionReviewUpdated::RemovedIssueCollectionBuilder)
      .to receive(:build)
      .and_return("removed_issues")
    allow(Builders::DecisionReviewUpdated::WithdrawnIssueCollectionBuilder)
      .to receive(:build)
      .and_return("withdrawn_issues")
    allow(Builders::DecisionReviewUpdated::IneligibleToIneligibleIssueCollectionBuilder)
      .to receive(:build)
      .and_return("ineligible_to_ineligible_issues")
  end

  let(:decision_review_updated_event) do
    create(:event, type: "Events::DecisionReviewUpdatedEvent", message_payload: message_payload)
  end
  let(:event_id) { decision_review_updated_event.id }

  describe "#initialize" do
    it "calls MetricsService.record with correct arguments" do
      expect(MetricsService).to receive(:record).with(
        "Build decision review updated #{decision_review_updated_event}",
        service: :dto_builder,
        name: "Builders::DecisionReviewUpdated::DtoBuilder.initialize"
      ).and_call_original

      dto_builder
    end

    it "initializes instance variables" do
      expect(dto_builder.instance_variable_get(:@event_id)).to eq(event_id)
      expect(dto_builder.instance_variable_get(:@decision_review_updated)).to be_a(Transformers::DecisionReviewUpdated)
    end
  end

  describe "#assign_from_builders" do
    it "builds and assigns attributes correctly" do
      dto_builder.send(:assign_from_builders)

      expect(dto_builder.instance_variable_get(:@claim_review)).to eq("claim_review")
      expect(dto_builder.instance_variable_get(:@end_product_establishment)).to eq("end_product_establishment")
      expect(dto_builder.instance_variable_get(:@added_issues)).to eq("added_issues")
      expect(dto_builder.instance_variable_get(:@updated_issues)).to eq("updated_issues")
      expect(dto_builder.instance_variable_get(:@removed_issues)).to eq("removed_issues")
      expect(dto_builder.instance_variable_get(:@withdrawn_issues)).to eq("withdrawn_issues")
      expect(dto_builder.instance_variable_get(:@ineligible_to_ineligible_issues))
        .to eq("ineligible_to_ineligible_issues")
    end

    describe "should rasie error if error in builder methods" do
      before do
        allow(dto_builder).to receive(:build_decision_review_updated_claim_review)
          .and_raise(AppealsConsumer::Error::DtoBuildError, "Some error")
      end
      it "should raise an error" do
        expect { subject.send(:assign_from_builders) }.to raise_error(AppealsConsumer::Error::DtoBuildError)
      end
    end
  end

  describe "#build_decision_review_updated" do
    it "returns an instance of Transformers::DecisionReviewUpdated" do
      result = dto_builder.send(:build_decision_review_updated, message_payload)
      expect(result).to be_a(Transformers::DecisionReviewUpdated)
    end
  end

  describe "#assign_from_decision_review_updated" do
    it "assigns attributes correctly" do
      allow(dto_builder.instance_variable_get(:@decision_review_updated)).to receive_messages(
        claim_id: "claim_123",
        actor_username: "user_123",
        decision_review_type: "type_123",
        actor_station: "station_123"
      )

      dto_builder.send(:assign_from_decision_review_updated)

      expect(dto_builder.instance_variable_get(:@claim_id)).to eq("claim_123")
      expect(dto_builder.instance_variable_get(:@css_id)).to eq("user_123")
      expect(dto_builder.instance_variable_get(:@detail_type)).to eq("type_123")
      expect(dto_builder.instance_variable_get(:@station)).to eq("station_123")
    end
  end

  describe "#build_decision_review_updated_payload" do
    let(:ineligible_to_ineligible_issues) do
      [FactoryBot.build(:decision_review_updated_request_issue, :ineligible_to_ineligible_request_issue)]
    end
    let(:cleaned_ineligible_to_ineligible_issues) do
      dto_builder.send(:clean_pii, ineligible_to_ineligible_issues)
    end
    let(:removed_issues) { [FactoryBot.build(:decision_review_updated_request_issue, :removed_request_issue)] }
    let(:cleaned_removed_issues) { dto_builder.send(:clean_pii, removed_issues) }

    # rubocop:disable Layout/LineLength
    it "returns the correct payload JSON object" do
      dto_builder.instance_variable_set(:@event_id, "event_123")
      dto_builder.instance_variable_set(:@claim_id, "claim_123")
      dto_builder.instance_variable_set(:@css_id, "css_123")
      dto_builder.instance_variable_set(:@detail_type, "type_123")
      dto_builder.instance_variable_set(:@station, "station_123")
      dto_builder.instance_variable_set(:@claim_review, FactoryBot.build(:decision_review_updated_claim_review))
      dto_builder.instance_variable_set(:@end_product_establishment, FactoryBot.build(:decision_review_updated_end_product_establishment))
      dto_builder.instance_variable_set(:@added_issues, "cleaned_added_issues")
      dto_builder.instance_variable_set(:@updated_issues, "cleaned_updated_issues")
      dto_builder.instance_variable_set(:@removed_issues, removed_issues)
      dto_builder.instance_variable_set(:@withdrawn_issues, "cleaned_withdrawn_issues")
      dto_builder.instance_variable_set(:@ineligible_to_ineligible_issues, ineligible_to_ineligible_issues)

      # rubocop:enable Layout/LineLength

      payload = dto_builder.send(:build_decision_review_updated_payload)
      expected_payload = {
        "event_id" => "event_123",
        "claim_id" => "claim_123",
        "css_id" => "css_123",
        "detail_type" => "type_123",
        "station" => "station_123",
        "claim_review" => { legacy_opt_in_approved: false, informal_conference: false, same_office: false },
        "end_product_establishment" => { development_item_reference_id: "123456", reference_id: "123456789" },
        "added_issues" => "cleaned_added_issues",
        "updated_issues" => "cleaned_updated_issues",
        "ineligible_to_ineligible_issues" => cleaned_ineligible_to_ineligible_issues,
        "removed_issues" => cleaned_removed_issues,
        "withdrawn_issues" => "cleaned_withdrawn_issues"
      }.as_json
      expect(payload).to eq(expected_payload)
    end
  end
end