# frozen_string_literal: true

describe MetricsService do
  let(:description) { "Test description" }
  let(:service) { "Consumer" }
  let(:name) { "Test" }
  let!(:event) { create(:decision_review_created_event, message_payload: decision_review_created.to_json) }
  let!(:event_id) { event.id }
  let!(:decision_review_created) { build(:decision_review_created) }

  describe ".record" do
    subject do
      MetricsService.record(description, service: service, name: name) do
        decision_review_created.instance_variable_set(:@event_id, event_id)
      end
    end

    context "Recording metrics" do
      it "Metrics are recorded with no errors" do
        allow(Rails.logger).to receive(:info)

        expect(MetricsService).to receive(:emit_gauge).with(
          hash_including(
            metric_group: "service",
            metric_name: "request_latency",
            metric_value: anything,
            app_name: "other",
            attrs: {
              service: service,
              endpoint: name,
              uuid: anything
            }
          )
        )
        expect(MetricsService).to receive(:increment_counter).with(
          metric_group: "service",
          app_name: "other",
          metric_name: "request_attempt",
          attrs: {
            service: service,
            endpoint: name
          }
        )
        expect(Rails.logger).to receive(:info)

        subject
      end
    end

    context "Recording metric errors" do
      it "Error raised, record metric error" do
        allow(Benchmark).to receive(:measure).and_raise(StandardError)

        expect(Rails.logger).to receive(:error)
        expect(MetricsService).to receive(:increment_counter).with(
          metric_group: "service",
          app_name: "other",
          metric_name: "request_error",
          attrs: {
            service: service,
            endpoint: name
          }
        )
        expect(MetricsService).to receive(:increment_counter).with(
          metric_group: "service",
          app_name: "other",
          metric_name: "request_attempt",
          attrs: {
            service: service,
            endpoint: name
          }
        )
        expect(Rails.logger).to receive(:info)
        expect { subject }.to raise_error(StandardError)
      end
    end
  end
end
