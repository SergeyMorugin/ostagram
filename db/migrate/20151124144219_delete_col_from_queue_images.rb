class DeleteColFromQueueImages < ActiveRecord::Migration
  def change
    remove_column :queue_images, :style_image
    remove_column :queue_images, :content_image
  end
end
