class Pimage < ActiveRecord::Base
  mount_uploader :imageurl, AvatarUploader
  belongs_to :queue_image




end
