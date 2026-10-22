class Vehicle < ApplicationRecord
  include NairaAttribute

  belongs_to :user

  enum :vehicle_type, { keke: "keke", okada: "okada", bus: "bus", car: "car", truck: "truck" }, validate: true
  enum :rate_frequency, { daily: "daily", weekly: "weekly" }, validate: true

  naira_attribute :rate

  # Monday first, the way people in Nigeria read a week. Values are Date#wday.
  WEEKDAYS = [ 1, 2, 3, 4, 5, 6, 0 ].freeze


  normalizes :plate_number, with: ->(plate) { plate.upcase.gsub(/[^A-Z0-9]/, "") }
  normalizes :nickname, with: ->(nickname) { nickname.squish.presence }
  normalizes :rest_days, with: ->(days) { days.compact.uniq.sort }

  # Rest days only make sense when money is due every day.
  before_validation -> { self.rest_days = [] }, if: :weekly?

  validates :plate_number, presence: true,
                           format: { with: /\A[A-Z0-9]{4,10}\z/, allow_blank: true, message: "should be 4–10 letters and numbers" },
                           uniqueness: { scope: :user_id, message: "is already one of your vehicles" }
  validates :nickname, length: { maximum: 50 }

  validates :rate_kobo, numericality: { only_integer: true, greater_than: 0, message: "must be an amount above ₦0, like 5,000" }
  validate :rest_days_leave_a_working_day

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_plate, -> { order(:plate_number) }

  def display_name
    nickname.present? ? "#{nickname} (#{plate_number})" : plate_number
  end

  # "Sun" or "Sat, Sun" for display.
  def rest_day_names
    WEEKDAYS.select { |wday| rest_days.include?(wday) }.map { |wday| Date::ABBR_DAYNAMES[wday] }.join(", ")
  end

  private
    def rest_days_leave_a_working_day
      errors.add(:rest_days, "can't include every day of the week") if rest_days.size >= 7
    end
end
