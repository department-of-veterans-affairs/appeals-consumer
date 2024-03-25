# frozen_string_literal: true

describe Builders::DecisionReviewCreated::VeteranBuilder do
  before do
    Timecop.freeze(Time.utc(2022, 1, 1, 12, 0, 0))
    Fakes::VeteranStore.new.store_veteran_record(decision_review_created.file_number, veteran_bis_record)
  end

  let!(:decision_review_created) { build(:decision_review_created) }
  let(:builder) { described_class.new(decision_review_created) }
  let(:bis_record) { builder.bis_record }
  let(:veteran_bis_record) do
    {
      file_number: decision_review_created.file_number,
      ptcpnt_id: decision_review_created.veteran_participant_id,
      sex: "M",
      first_name: decision_review_created.veteran_first_name,
      middle_name: "Russell",
      last_name: decision_review_created.veteran_last_name,
      name_suffix: "II",
      ssn: "987654321",
      address_line1: "122 Mullberry St.",
      address_line2: "PO BOX 123",
      address_line3: "Daisies",
      city: "Orlando",
      state: "FL",
      country: "USA",
      date_of_birth: "12/21/1989",
      date_of_death: "12/31/2019",
      zip_code: "94117",
      military_post_office_type_code: nil,
      military_postal_type_code: nil,
      service: [{ branch_of_service: "army", pay_grade: "E4" }]
    }
  end

  describe "#build" do
    subject { described_class.build(decision_review_created) }
    it "returns a DecisionReviewCreated::Veteran object" do
      expect(subject).to be_an_instance_of(DecisionReviewCreated::Veteran)
    end
  end

  describe "#initialize(decision_review_created)" do
    let(:veteran) { described_class.new(decision_review_created).veteran }

    it "initializes a new VeteranBuilder instance" do
      expect(builder).to be_an_instance_of(described_class)
    end

    it "initializes a new DecisionReviewCreated::Veteran object" do
      expect(veteran).to be_an_instance_of(DecisionReviewCreated::Veteran)
    end

    it "assigns decision_review_created to the DecisionReviewCreated object passed in" do
      expect(builder.decision_review_created).to be_an_instance_of(Mappers::DecisionReviewCreated)
    end

    it "assigns bis_record to the veteran record fetched from BIS" do
      expect(builder.bis_record).to eq(veteran_bis_record)
    end
  end

  describe "#assign_attributes" do
    it "calls private methods" do
      expect(builder).to receive(:assign_participant_id)
      expect(builder).to receive(:calculate_bgs_last_synced_at)
      expect(builder).to receive(:calculate_date_of_death)
      expect(builder).to receive(:calculate_name_suffix)
      expect(builder).to receive(:calculate_ssn)
      expect(builder).to receive(:assign_file_number)
      expect(builder).to receive(:assign_first_name)
      expect(builder).to receive(:calculate_middle_name)
      expect(builder).to receive(:assign_last_name)

      builder.assign_attributes
    end
  end

  describe "#assign_participant_id" do
    subject { builder.send(:assign_participant_id) }
    it "assigns the veteran's participant_id to decision_review_created.veteran_participant_id" do
      expect(subject).to eq(decision_review_created.veteran_participant_id)
    end
  end

  describe "#calculate_bgs_last_synced_at" do
    subject { builder.send(:calculate_bgs_last_synced_at) }

    it "assigns the veteran's bgs_last_synced_at to the datetime BIS was called in milliseconds"\
     " (@bis_synced_at initialized in Builders::ModelBuilder#fetch_veteran_bis_record)" do
      expect(subject).to eq(Time.zone.now.to_i * 1000)
    end
  end

  describe "#assign_file_number" do
    subject { builder.send(:assign_file_number) }
    it "assigns the veteran's file_number to decision_review_created.file_number" do
      expect(subject).to eq(decision_review_created.file_number)
    end
  end

  describe "#assign_first_name" do
    subject { builder.send(:assign_first_name) }
    it "assigns the veteran's first_name to decision_review_created.veteran_first_name" do
      expect(subject).to eq(decision_review_created.veteran_first_name)
    end
  end

  describe "#assign_last_name" do
    subject { builder.send(:assign_last_name) }
    it "assigns the veteran's first_name to decision_review_created.veteran_first_name" do
      expect(subject).to eq(decision_review_created.veteran_last_name)
    end
  end

  describe "#calculate_date_of_death" do
    subject { builder.send(:calculate_date_of_death) }
    let(:epoch_date) { ModelBuilder::EPOCH_DATE }
    let(:date_of_death) { bis_record[:date_of_death] }
    let(:target_date) { Date.strptime(date_of_death, "%m/%d/%Y") }
    let(:date_of_death_logical_type) { (target_date - epoch_date).to_i }

    it "assigns the veteran's date_of_death to the date_of_death retrieved from BIS converted to logical type int" do
      expect(subject).to eq(date_of_death_logical_type)
    end
  end

  describe "#calculate_name_suffix" do
    subject { builder.send(:calculate_name_suffix) }
    it "assigns the veteran's name_suffix to the name_suffix value retrieved from BIS" do
      expect(subject).to eq(bis_record[:name_suffix])
    end
  end

  describe "#calculate_ssn" do
    subject { builder.send(:calculate_ssn) }
    it "assigns the veteran's ssn to the ssn value retrieved from BIS" do
      expect(subject).to eq(bis_record[:ssn])
    end
  end

  describe "#calculate_middle_name" do
    subject { builder.send(:calculate_middle_name) }
    it "assigns the veteran's middle_name to the middle_name value retrieved from BIS" do
      expect(subject).to eq(bis_record[:middle_name])
    end
  end
end
