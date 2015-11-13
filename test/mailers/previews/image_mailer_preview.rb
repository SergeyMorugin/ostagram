# Preview all emails at http://localhost:3000/rails/mailers/image_mailer
class ImageMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/image_mailer/send_image
  def send_image
    ImageMailer.send_image
  end

  # Preview this email at http://localhost:3000/rails/mailers/image_mailer/send_error
  def send_error
    ImageMailer.send_error
  end

end
