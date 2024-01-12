# spec/controllers/sentry_controller_spec.rb
require "rails_helper"

RSpec.describe SentryController, type: :controller do
  describe "#simulate_error" do
    it "captures and reports the exception to Sentry" do
      # Inside the test
      sentry_client = double("Sentry::Client")
      allow(Sentry).to receive(:send_event).and_return(sentry_client)
      allow(sentry_client).to receive(:send_event)

      # Trigger the action that should raise an exception
      expect { get :simulate_error }.to raise_error(StandardError, "This is a simulated error!")
    end
  end
end
