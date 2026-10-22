# Lets a form work in naira while the database column stays in kobo.
#
#   class Vehicle < ApplicationRecord
#     include NairaAttribute
#     naira_attribute :rate    # needs a `rate_kobo` column
#   end
#
#   vehicle.rate_naira = "5,000"   # sets rate_kobo = 500_000
#   vehicle.rate_naira             # => "5,000" (what was typed) or "5000" (from the DB)
#
# The form field is `rate_naira`, a "virtual attribute" (a getter/setter pair
# with no column behind it). Payments and assignment rate overrides will reuse
# this in Phase 2, which is why it's a concern and not code inside Vehicle.
#
# If the input isn't a valid amount, `rate_kobo` becomes nil, so the model's
# own validation on `rate_kobo` reports the error.
module NairaAttribute
  extend ActiveSupport::Concern

  class_methods do
    def naira_attribute(name)
      kobo_column = :"#{name}_kobo"
      naira_field = :"#{name}_naira"

      # define_method creates instance methods at class-load time, like writing
      # `def rate_naira ... end` by hand for each attribute.
      define_method(naira_field) do
        # Show exactly what was typed (even if invalid) so the owner can fix it.
        naira_inputs.fetch(naira_field) { Naira.to_input(public_send(kobo_column)) }
      end

      define_method(:"#{naira_field}=") do |value|
        naira_inputs[naira_field] = value
        public_send(:"#{kobo_column}=", Naira.to_kobo(value))
      end
    end
  end

  private
    def naira_inputs
      @naira_inputs ||= {}
    end
end
