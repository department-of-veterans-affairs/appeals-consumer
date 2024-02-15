require 'bgs'

module Fakes
  class BISService 
    class << self
      def clean!
        veteran_store.clear!
      end

      def veteran_store
        @veteran_store ||= Fakes::VeteranStore.new
      end

      delegate :store_veteran_record, to: :veteran_store

      def get_veteran_record(file_number)
        veteran_store.fetch_and_inflate(file_number)
      end
    end

    def get_veteran_record(file_number)
      self.class.get_veteran_record(file_number)
    end

    def fetch_veteran_info(file_number)
      get_veteran_record(file_number)
    end

    # rubocop:disable Metrics/MethodLength
    def fetch_person_info(participant_id)
      # This is a limited set of test data, more fields are available.
      if participant_id == "5382910292"
        # This claimant is over 75 years old so they get automatic AOD
        {
          birth_date: DateTime.new(1943, 9, 5),
          first_name: "Bob",
          middle_name: "Billy",
          last_name: "Vance",
          ssn_nbr: "666001234",
          email_address: "bob.vance@caseflow.gov"
        }
      elsif participant_id == "1129318238"
        {
          birth_date: DateTime.new(1998, 9, 5),
          first_name: "Cathy",
          middle_name: "",
          last_name: "Smith",
          name_suffix: "Jr.",
          ssn_nbr: "666002222",
          email_address: "cathy.smith@caseflow.gov"
        }
      elsif participant_id == "600153863"
        {
          birth_date: DateTime.new(1998, 9, 5),
          fist_name: "Clarence",
          middle_name: "",
          last_name: "Darrow",
          ssn_nbr: "666003333",
          email_address: "clarence.darrow@caseflow.gov"
        }
      elsif participant_id.starts_with?("RANDOM_CLAIMANT_PID")
        first_name = Faker::Name.first_name
        last_name = Faker::Name.last_name
        {
          birth_date: Faker::Date.birthday(min_age: 35, max_age: 80).to_datetime,
          first_name: first_name,
          middle_name: "",
          last_name: last_name,
          ssn_nbr: "666005555",
          email_address: "#{first_name}.#{last_name}@email.com"
        }
      elsif participant_id == ""
        {} # simulates returned value for unrecognized appellant
      else
        {
          birth_date: DateTime.new(1998, 9, 5),
          first_name: "Tom",
          middle_name: "Edward",
          last_name: "Brady",
          ssn_nbr: "666004444",
          email_address: "tom.brady@caseflow.gov"
        }
      end
    end

    def fetch_limited_poas_by_claim_ids(claim_ids)
      result = {}
      Array.wrap(claim_ids).each do |claim_id|
        result[claim_id] = if claim_id.to_i.even?
                             { limited_poa_code: "OU3", limited_poa_access: "Y" }
                           else
                             { limited_poa_code: "007", limited_poa_access: "N" }
                           end
      end

      result.empty? ? nil : result
    end
  end
end