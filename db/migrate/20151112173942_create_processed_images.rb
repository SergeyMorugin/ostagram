class CreateProcessedImages < ActiveRecord::Migration
  def change
    create_table :processed_images do |t|
      t.integer :queque_image_id
      t.integer :iter
      t.string :image

      t.timestamps null: false
    end
  end
end
