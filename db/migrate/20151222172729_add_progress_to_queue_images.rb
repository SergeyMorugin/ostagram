class AddProgressToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :progress, :float, default: 0
  end
end
