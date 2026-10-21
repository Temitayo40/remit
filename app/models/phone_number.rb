# Phonelib (a gem) is the heavyweight alternative; we only need Nigerian
module PhoneNumber

  FORMAT = /\A\+234[789]\d{9}\z/

  def self.normalize(raw)
    return if raw.blank?

    digits = raw.to_s.gsub(/[^\d]/, "") # drop spaces, dashes, brackets, "+"

    national =
      case digits
      when /\A2340?(\d{10})\z/   then $1 # 234803..., or the common 2340803... mistake
      when /\A0(\d{10})\z/       then $1 # 0803...
      when /\A(\d{10})\z/        then $1 # 803... (leading 0 forgotten)
      end

    national ? "+234#{national}" : raw.to_s.strip
  end

  def self.valid?(value)
    FORMAT.match?(value.to_s)
  end
end
