class ImageMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_image.subject
  #
  def send_image
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_error.subject
  #
  def send_error
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
