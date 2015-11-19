class QueueImage < ActiveRecord::Base
  has_many :pimages , dependent: :destroy
  belongs_to :client
  mount_uploader :content_image, AvatarUploader
  mount_uploader :style_image, AvatarUploader

  def result_image
    if pimages.count > 0
      pimages.all.order('created_at DESC').first
    end
  end
end
