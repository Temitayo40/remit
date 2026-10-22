class Driver < ApplicationRecord
  belongs_to :user

  normalizes :name, :guarantor_name, with: ->(value) { value.squish.presence }
  normalizes :phone, :guarantor_phone, with: ->(value) { PhoneNumber.normalize(value) }
  normalizes :notes, with: ->(value) { value.strip.presence }

  PHONE_MESSAGE = "must be a Nigerian mobile number, e.g. 0803 123 4567".freeze

  validates :name, presence: true, length: { maximum: 100 }
  validates :phone, presence: true,
                    format: { with: PhoneNumber::FORMAT, allow_blank: true, message: PHONE_MESSAGE },
                    uniqueness: { scope: :user_id, message: "already belongs to one of your drivers" }
  validates :guarantor_name, length: { maximum: 100 }
  validates :guarantor_phone, format: { with: PhoneNumber::FORMAT, allow_blank: true, message: PHONE_MESSAGE }
  validates :notes, length: { maximum: 1000 }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_name, -> { order(:name) }
end
