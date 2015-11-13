class AddStimeAndFtimeToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :stime, :time
    add_column :queue_images, :ftime, :time
  end
end
