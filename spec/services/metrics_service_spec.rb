# frozen_string_literal: true

describe MetricsService do
  let(:description) { "Test description" }
  let(:service) { "Consumer" }
  let(:name) { "Test" }
  let!(:event) { create(:decision_review_created_event, message_payload: decision_review_created.to_json) }
  let!(:event_id) { event.id }
  let!(:decision_review_created) { build(:decision_review_created) }
  let(:metric_group) { "service" }
  let(:metric_name) { "test_metric" }
  let(:metric_value) { 42 }
  let(:app_name) { "test_app" }
  let(:attrs) { { service: "test_service", endpoint: "test_endpoint" } }

  describe ".record" do
    subject do
      MetricsService.record(description, service: service, name: name) do
        decision_review_created.instance_variable_set(:@event_id, event_id)
      end
    end

    context "Recording metrics" do
      it "Metrics are recorded with no errors" do
        allow(Rails.logger).to receive(:info)
        allow(MetricsService).to receive(:emit_gauge)

        expect(MetricsService).to receive(:emit_gauge).with(
          hash_including(
            metric_group: "service",
            metric_name: "request_latency",
            metric_value: anything,
            app_name: "appeals-consumer",
            attrs: {
              service: service,
              endpoint: name
            }
          )
        )
        expect(MetricsService).to receive(:increment_counter).with(
          metric_group: "service",
          app_name: "appeals-consumer",
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
          app_name: "appeals-consumer",
          metric_name: "request_error",
          attrs: {
            service: service,
            endpoint: name
          }
        )
        expect(MetricsService).to receive(:increment_counter).with(
          metric_group: "service",
          app_name: "appeals-consumer",
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

  describe ".emit_gauge" do
    it "calls StatsD.gauge with the correct arguments" do
      allow(StatsD).to receive(:gauge)
      rails_env = Rails.env

      expect(StatsD).to receive(:gauge).with(
        "dsva-appeals.service.test_metric",
        metric_value,
        tags: ["app:test_app", "env:#{rails_env}", "service:test_service", "endpoint:test_endpoint"]
      )

      MetricsService.emit_gauge(
        metric_group: metric_group,
        metric_name: metric_name,
        metric_value: metric_value,
        app_name: app_name,
        attrs: attrs
      )
    end
  end

  describe ".increment_counter" do
    it "calls StatsD.increment with the correct arguments" do
      allow(StatsD).to receive(:increment)
      rails_env = Rails.env

      expect(StatsD).to receive(:increment).with(
        "dsva-appeals.service.test_metric",
        tags: ["app:test_app", "env:#{rails_env}", "service:test_service", "endpoint:test_endpoint"]
      )

      MetricsService.increment_counter(
        metric_group: metric_group,
        metric_name: metric_name,
        app_name: app_name,
        attrs: attrs
      )
    end
  end

  describe ".record_runtime" do
    it "calls MetricsService.emit_gauge with the correct arguments" do
      expect(MetricsService).to receive(:emit_gauge).with(
        app_name: app_name,
        metric_group: metric_group,
        metric_name: "runtime",
        metric_value: anything
      )

      MetricsService.record_runtime(
        metric_group: metric_group,
        app_name: app_name
      )
    end
  end
end
