class Content < ActiveRecord::Base
  has_many :queue_images
  mount_uploader :image, AvatarUploader

end
