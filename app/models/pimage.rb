class Pimage < ActiveRecord::Base
  mount_uploader :imageurl, PimageUploader
  belongs_to :queue_image
end
