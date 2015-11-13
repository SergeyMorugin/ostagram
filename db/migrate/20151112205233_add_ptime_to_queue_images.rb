class AddPtimeToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :ptime, :time
  end
end
