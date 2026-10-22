# A person who drives an owner's vehicle and owes them remittance.
# Drivers never log in. They're identified by phone number, where receipts
# and reminders will be sent in Phase 4.
class CreateDrivers < ActiveRecord::Migration[8.1]
  def change
    create_table :drivers do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      # Normalized "+234XXXXXXXXXX" (PhoneNumber), same as owners.
      t.string :phone, null: false

      # The person who vouches for the driver. Optional: not every owner uses one.
      t.string :guarantor_name
      t.string :guarantor_phone

      t.text :notes

      # Like vehicles: never deleted, just marked as no longer driving.
      t.boolean :active, null: false, default: true
      # README section 8: the owner can switch automatic reminders off per driver.
      t.boolean :reminders_enabled, null: false, default: true

      t.timestamps
    end

    # One owner can't add the same driver twice. The same driver may drive for
    # several owners, so uniqueness is per owner.
    add_index :drivers, [ :user_id, :phone ], unique: true
  end
end
