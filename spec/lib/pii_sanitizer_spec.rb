# frozen_string_literal: true

describe PiiSanitizer do
  describe ".sanitize" do
    context "when data contains PII fields with symbol keys" do
      it "redacts PII fields and preserves non-PII data" do
        data = {
          ssn: "123-45-6789",
          first_name: "John",
          last_name: "Doe",
          non_pii: "Non-PII data"
        }

        sanitized_data = described_class.sanitize(data)

        expect(sanitized_data[:ssn]).to eq("[REDACTED]")
        expect(sanitized_data[:first_name]).to eq("[REDACTED]")
        expect(sanitized_data[:last_name]).to eq("[REDACTED]")
        expect(sanitized_data[:non_pii]).to eq("Non-PII data")
      end
    end

    context "when data contains PII fields with strings keys" do
      it "redacts PII fields and preserves non-PII data" do
        data = {
          "ssn" => "123-45-6789",
          "first_name" => "John",
          "last_name" => "Doe",
          "non_pii" => "Non-PII data"
        }

        sanitized_data = described_class.sanitize(data)

        expect(sanitized_data["ssn"]).to eq("[REDACTED]")
        expect(sanitized_data["first_name"]).to eq("[REDACTED]")
        expect(sanitized_data["last_name"]).to eq("[REDACTED]")
        expect(sanitized_data["non_pii"]).to eq("Non-PII data")
      end
    end

    context "when data contains nested arrays with PII fields" do
      it "recursively redacts PII fields in all nested structures" do
        data = {
          ssn: "123-45-6789",
          relatives: [
            { first_name: "John", last_name: "Doe", relationship: "Father" },
            { first_name: "Jane", last_name: "Smith", relationship: "Mother" }
          ],
          non_pii: "Non-PII data"
        }

        sanitized_data = described_class.sanitize(data)

        expect(sanitized_data[:ssn]).to eq("[REDACTED]")
        expect(sanitized_data[:relatives][0][:first_name]).to eq("[REDACTED]")
        expect(sanitized_data[:relatives][0][:last_name]).to eq("[REDACTED]")
        expect(sanitized_data[:relatives][1][:first_name]).to eq("[REDACTED]")
        expect(sanitized_data[:relatives][1][:last_name]).to eq("[REDACTED]")
        expect(sanitized_data[:relatives][0][:relationship]).to eq("Father")
        expect(sanitized_data[:relatives][1][:relationship]).to eq("Mother")
        expect(sanitized_data[:non_pii]).to eq("Non-PII data")
      end
    end
  end
end
