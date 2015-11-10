class CreateQueueImages < ActiveRecord::Migration
  def change
    create_table :queue_images do |t|
      t.integer :user_id
      t.string :content_image
      t.string :style_image
      t.string :init_str, default: ""
      t.integer :status , default: 1
      t.string :result

      t.timestamps null: false
    end
  end
end
