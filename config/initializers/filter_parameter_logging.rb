# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
#
# Remit stores personal data about owners, drivers and guarantors (NDPA 2023).
# Partial matching means :phone also hides guarantor_phone, and :name also
# hides guarantor_name, so new fields are covered without editing this list.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  :phone, :name
]
