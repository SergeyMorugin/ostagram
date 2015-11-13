class AddStimeAndFtimeToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :stime, :datetime
    add_column :queue_images, :ftime, :datetime
  end
end
