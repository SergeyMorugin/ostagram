class Like < ActiveRecord::Base
  belongs_to :queue_image
  belongs_to :client
end
