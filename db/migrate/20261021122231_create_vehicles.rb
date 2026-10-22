# A vehicle the owner hires out: keke, okada, bus, car or truck.
#
# Model validations give friendly errors, but this migration also adds
# database-level rules (NOT NULL, CHECK constraints, unique indexes). Those
# still hold if a bug, a console session or a future script bypasses the model.
# For financial records, the database is the last line of defence.
class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      # Every vehicle belongs to exactly one owner. foreign_key: the DB refuses
      # a vehicle pointing at a user that doesn't exist.
      t.references :user, null: false, foreign_key: true

      # Stored compact and upper-case ("LND123AB"), see Vehicle.normalizes.
      t.string :plate_number, null: false
      # String-backed enum: the DB holds readable "keke", not a mystery integer.
      t.string :vehicle_type, null: false
      t.string :nickname

      # Money is ALWAYS integer kobo (₦1 = 100 kobo). Floats can't represent
      # money exactly (0.1 + 0.2 != 0.3). bigint because some fleets and later
      # summaries add up past the 2.1 billion limit of a normal integer.
      t.bigint :rate_kobo, null: false
      t.string :rate_frequency, null: false, default: "daily"

      # Days of the week with no remittance due. Ruby's Date#wday numbering:
      # 0 = Sunday ... 6 = Saturday. A Postgres array keeps it in one column.
      t.integer :rest_days, array: true, null: false, default: []

      # Vehicles are never deleted (they'll carry payment history). Taking one
      # out of service just sets active = false.
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    # The same owner can't add one plate twice. A different owner may have the
    # same plate (a vehicle can be sold), so uniqueness is per owner.
    add_index :vehicles, [ :user_id, :plate_number ], unique: true

    add_check_constraint :vehicles, "vehicle_type IN ('keke', 'okada', 'bus', 'car', 'truck')", name: "vehicles_vehicle_type_valid"
    add_check_constraint :vehicles, "rate_frequency IN ('daily', 'weekly')", name: "vehicles_rate_frequency_valid"
    add_check_constraint :vehicles, "rate_kobo > 0", name: "vehicles_rate_kobo_positive"
    # <@ means "is contained by": every value must be a weekday number 0–6.
    add_check_constraint :vehicles, "rest_days <@ ARRAY[0,1,2,3,4,5,6]", name: "vehicles_rest_days_valid"
  end
end
