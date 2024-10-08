# frozen_string_literal: true

class Builders::PersonUpdated::PersonBuilder < Builders::BasePersonBuilder
  def initialize(person_updated_model)
    @person = PersonUpdated::Person.new
    super
  end
end
