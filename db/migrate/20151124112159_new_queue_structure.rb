class NewQueueStructure < ActiveRecord::Migration
  def up
    add_column :queue_images, :style_id,   :integer, null: false, default: 0
    add_column :queue_images, :content_id, :integer, null: false, default: 0
    add_column :queue_images, :end_status, :integer, null: false, default: 11

    QueueImage.find_each do |qi|
      si = Style.new
      si.image = qi.style_image
      si.save

      ci = Content.new
      ci.image = qi.content_image
      ci.save

      qi.style_id = ci.id
      qi.content_id = ci.id
      qi.save
    end

  end

  def down
    remove_column :queue_images, :style_id,   :integer
    remove_column :queue_images, :content_id, :integer
    remove_column :queue_images, :end_status, :integer
  end
end
