class ImageMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_image.subject
  #
  def send_image(user, iter, max_iter, file)
      attachments['out.png'] = file
      mail(to: user.email, subject: "Ваше изображение обработано")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.image_mailer.send_error.subject
  #
  def send_error(email, message, queue,file)
    #@errors = message
    attachments['error.txt'] = file
    mail(to: email, subject: 'Ostagram ERROR')
  end
end
