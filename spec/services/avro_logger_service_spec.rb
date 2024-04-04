# frozen_string_literal: true

RSpec.describe AvroLoggerService, type: :service do
  subject { AvroLoggerService.new($stderr) }

  describe "hard coded constants are set correctly" do
    it "should have ERROR_MSG set correctly" do
      expect(subject.class::ERROR_MSG).to eq "Error running AvroDeserializerService"
    end

    it "should have SERVICE_NAME set correctly" do
      expect(subject.class::SERVICE_NAME).to eq "AvroDeserializerService"
    end
  end

  describe "#methods" do
    let(:error) { StandardError.new }

    describe "#error" do
      it "should report an error with no block given" do
        expect_any_instance_of(LoggerService).to receive(:error).with(error, notify_alerts: true)

        subject.error(error)
      end

      it "should report an error with a block given" do
        expect_any_instance_of(LoggerService).to receive(:error) { "yielding a block" }

        subject.error(error)
      end
    end
  end
end
