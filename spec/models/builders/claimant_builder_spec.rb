# frozen_string_literal: true

describe Builders::ClaimantBuilder do
  let(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let(:bis_record) { builder.bis_record }
  let(:claimant_bis_record) { Fakes::BISService.new.fetch_person_info(decision_review_created.claimant_participant_id) }

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a Claimant object" do
      expect(subject).to be_an_instance_of(Claimant)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:claimant) { described_class.new(decision_review_created).claimant }

    it "initializes a new ClaimantBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new Claimant object" do
      expect(claimant).to be_an_instance_of(Claimant)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(DecisionReviewCreated)
    end

    it "assigns bis_record to the claimant record fetched from BIS" do
      expect(builder.bis_record).to eq(claimant_bis_record)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:assign_payee_code)
      expect(builder).to receive(:calculate_type)
      expect(builder).to receive(:assign_participant_id)
      expect(builder).to receive(:calculate_name_suffix)
      expect(builder).to receive(:calculate_ssn)
      expect(builder).to receive(:calculate_date_of_birth)
      expect(builder).to receive(:calculate_first_name)
      expect(builder).to receive(:calculate_middle_name)
      expect(builder).to receive(:calculate_last_name)
      expect(builder).to receive(:calculate_email)

      builder.assign_attributes
    end
  end

  describe "#assign_payee_code" do
    subject { builder.send(:assign_payee_code) }
    it "assigns the claimant's payee_code to the decision_review_created.payee_code" do
      expect(subject).to eq(decision_review_created.payee_code)
    end
  end

  #  TODO: check for both types
  describe "#calculate_type" do
    subject { builder.send(:calculate_type) }
    it "assigns the claimant's type to the 'VeteranClaimant' when the payee code is '00'" do
      allow(builder).to receive(:fetch_bis_record).and_return(claimant_bis_record)
      subject
      builder.send(:fetch_bis_record)

      expect(subject).to eq("VeteranClaimant")
    end
  end

  describe "#assign_participant_id" do
    subject { builder.send(:assign_participant_id) }
    it "assigns the claimant's participant_id to the decision_review_created.claimant_participant_id" do
      expect(subject).to eq(decision_review_created.claimant_participant_id)
    end
  end

  describe "#calculate_name_suffix" do
    subject { builder.send(:calculate_name_suffix) }
    it "assigns the claimant's name_suffix to the name_suffix value retrieved from BIS" do
      expect(subject).to eq(bis_record[:name_suffix])
    end
  end

  describe "#calculate_ssn" do
    subject { builder.send(:calculate_ssn) }
    it "assigns the claimant's ssn to the ssn value retrieved from BIS" do
      expect(subject).to eq(bis_record[:ssn])
    end
  end

  describe "#calculate_date_of_birth" do
    subject { builder.send(:calculate_date_of_birth) }
    it "assigns the claimant's date_of_birth to the birth_date from BIS in Unix Time (milliseconds since epoch)" do
      expect(subject).to eq(bis_record[:birth_date].to_i * 1000)
    end
  end

  describe "#calculate_first_name" do
    subject { builder.send(:calculate_first_name) }
    it "assigns the claimant's first_name to the first_name from BIS" do
      expect(subject).to eq(bis_record[:first_name])
    end
  end

  describe "#calculate_middle_name" do
    subject { builder.send(:calculate_middle_name) }
    it "assigns the claimant's middle_name to the middle_name from BIS" do
      expect(subject).to eq(bis_record[:middle_name])
    end
  end

  describe "#calculate_last_name" do
    subject { builder.send(:calculate_last_name) }
    it "assigns the claimant's last_name to the last_name from BIS" do
      expect(subject).to eq(bis_record[:last_name])
    end
  end

  describe "#calculate_email" do
    subject { builder.send(:calculate_email) }
    it "assigns the claimant's email to the email_address from BIS" do
      expect(subject).to eq(bis_record[:email_address])
    end
  end

  describe "#fetch_bis_record" do
    let(:error) { AppealsConsumer::Error::BisClaimantNotFound }
    let(:error_msg) do
      "DecisionReviewCreated claimant_participant_id"\
     " #{decision_review_created.claimant_participant_id} does not have a valid BIS record"
    end
    subject { builder.send(:fetch_bis_record) }

    context "when the bis record is found and is valid" do
      it "returns the bis record" do
        expect(subject).to eq(claimant_bis_record)
      end
    end

    context "when the bis record is not found" do
      before do
        allow_any_instance_of(BISService).to receive(:fetch_person_info).and_return({})
      end
      it "raises error AppealsConsumer::Error::BisClaimantNotFound with error message" do
        expect { subject }.to raise_error(error, error_msg)
      end
    end
  end
end
