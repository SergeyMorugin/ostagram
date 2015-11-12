class CreateProcessedImages < ActiveRecord::Migration
  def change
    create_table :processed_images do |t|
      t.integer :queque_image_id, null: false
      t.integer :iter, null: false
      t.string :image, null: false

      t.timestamps null: false
    end
  end
end
