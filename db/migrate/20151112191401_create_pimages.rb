class CreatePimages < ActiveRecord::Migration
  def change
    create_table :pimages do |t|
      t.integer :queue_image_id
      t.integer :iterate
      t.string :imageurl

      t.timestamps null: false
    end
  end
end
