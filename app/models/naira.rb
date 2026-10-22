
module Naira
  # Digits, optionally followed by up to 2 decimal places (kobo).
  AMOUNT = /\A\d+(\.\d{1,2})?\z/

  # Returns kobo as an Integer, or nil when the input isn't a valid amount.
  def self.to_kobo(input)
    return if input.blank?

    cleaned = input.to_s.gsub(/[₦,\s]/, "") # people type "₦5,000" or "5 000"
    return unless AMOUNT.match?(cleaned)

    (BigDecimal(cleaned) * 100).to_i
  end

  # For display: "₦5,000", or "₦5,000.50" only when there are kobo.
  def self.format(kobo)
    return "" if kobo.nil?

    ActiveSupport::NumberHelper.number_to_currency(
      BigDecimal(kobo) / 100,
      unit: "₦",
      precision: (kobo % 100).zero? ? 0 : 2
    )
  end

  # For refilling a form field: "5000" or "5000.50" (no symbol, no commas).
  def self.to_input(kobo)
    return if kobo.nil?

    naira, remainder = kobo.divmod(100)
    remainder.zero? ? naira.to_s : "#{naira}.#{remainder.to_s.rjust(2, "0")}"
  end
end
