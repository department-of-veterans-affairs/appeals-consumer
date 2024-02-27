# frozen_string_literal: true

RSpec.describe BaseEventProcessingJob, type: :job do
  let!(:event) { create(:event) }

  describe "#perform_now" do
    it "should pass" do
    end
  end

  describe "#ended_at" do
    it "should pass" do
    end
  end
end
