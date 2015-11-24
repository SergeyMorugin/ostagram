class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string  :image,  null: false
      t.integer :status, null: false, default: 0

      t.timestamps       null: false
    end
  end
end
