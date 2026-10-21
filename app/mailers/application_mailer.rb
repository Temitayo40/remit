class ApplicationMailer < ActionMailer::Base
  # The real sending address depends on the email provider we pick before
  # launch (needs a verified domain). Set MAILER_FROM in production.
  default from: ENV.fetch("MAILER_FROM", "Remit <no-reply@example.com>")
  layout "mailer"
end
