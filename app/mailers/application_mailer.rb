class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "no-reply@worldcuppool.app")
  layout "mailer"
end
