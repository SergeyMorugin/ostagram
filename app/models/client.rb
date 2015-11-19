class Client < ActiveRecord::Base
  has_many :queue_images
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :, :lockable, :timeoutable and :omniauthable :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable
end
