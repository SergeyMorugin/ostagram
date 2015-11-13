class User < ActiveRecord::Base
  has_many :queue_images

  def create_by_email(email)
    usr = Ures.where("email = #{email}")
    if usr.nil?
      usr = User.create({email: email})
      usr.save
    end
    usr
  end


end
