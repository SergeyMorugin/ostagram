class AddLikesToQueueImages < ActiveRecord::Migration
  def up
    add_column :queue_images, :likes_count, :integer, default: 0
    QueueImage.find_each do |qi|
      qi.likes_count = Like.where(queue_id: qi.id).count
      qi.save
    end
  end

  def down
    remove_column :queue_images, :likes_count
  end
end
