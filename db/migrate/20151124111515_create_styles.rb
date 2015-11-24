class CreateStyles < ActiveRecord::Migration
  def change
    create_table :styles do |t|
      t.string  :image,       null: false
      t.string  :init
      t.integer :status,      null: false, default: 0
      t.integer :use_counter, null: false, default: 0

      t.timestamps            null: false
    end
  end
end
