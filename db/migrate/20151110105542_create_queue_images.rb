class CreateQueueImages < ActiveRecord::Migration
  def change
    create_table :queue_images do |t|
      t.integer :client_id, null: false
      t.string :content_image, null: false
      t.string :style_image, null: false
      t.string :init_str, default: ""
      t.integer :status, default: 0
      t.string :result, default: ""

      t.timestamps null: false
    end
  end
end
