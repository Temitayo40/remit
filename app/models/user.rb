class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :drivers, dependent: :destroy

  MINIMUM_PASSWORD_LENGTH = 8

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.squish }
  normalizes :phone, with: ->(p) { PhoneNumber.normalize(p) }

  validates :name, presence: true, length: { maximum: 100 }
  validates :email_address, presence: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP },
                            uniqueness: true 
  # Phone is a login identifier (like email), so it must be unique too.
  validates :phone, presence: true,
                    format: { with: PhoneNumber::FORMAT, message: "must be a Nigerian mobile number, e.g. 0803 123 4567" },
                    uniqueness: { message: "is already registered. Try logging in instead" }

  validates :password, length: { minimum: MINIMUM_PASSWORD_LENGTH }, allow_nil: true
end
