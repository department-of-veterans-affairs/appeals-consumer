# frozen_string_literal: true

FactoryBot.define do
  factory :rating_profile_response, class: OpenStruct do
    data do
      JSON.parse(File.read("spec/fixtures/bis_response.json")).deep_symbolize_keys
    end

    trait :diagnostic_code_nil do
      data do
        JSON.parse(File.read("spec/fixtures/diagnostic_code_nil_bis_response.json")).deep_symbolize_keys
      end
    end

    trait :error_response do
      data do
        JSON.parse(File.read("spec/fixtures/error_bis_response.json")).deep_symbolize_keys
      end
    end

    trait :no_data do
      data do
        JSON.parse(File.read("spec/fixtures/no_data_bis_response.json")).deep_symbolize_keys
      end
    end

    trait :promulgation_date_nil do
      data do
        JSON.parse(File.read("spec/fixtures/promulgation_date_nil_bis_response.json")).deep_symbolize_keys
      end
    end

    trait :subject_text_nil do
      data do
        JSON.parse(File.read("spec/fixtures/subject_text_nil_bis_response.json")).deep_symbolize_keys
      end
    end
  end
end
