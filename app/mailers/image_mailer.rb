class ImageMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_image.subject
  #
  def send_image(iter, max_iter, file)
      attachments['out.png'] = file
      mail(to: "cmorugin@gmail.com", subject: "Ваше изображение обработано на #{iter}/#{max_iter}")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_error.subject
  #
  def send_error(file)
    @greeting = "Hi"
    attachments['out.png'] = file
    mail(to: "cmorugin@gmail.com", subject: 'Image finish')
  end
end
