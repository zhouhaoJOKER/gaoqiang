class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.string :sign
      t.integer :parent_id
      t.string :name
      t.string :py
      t.integer :sort
      t.string :color
      t.boolean :is_open
      t.integer :user_id

      t.timestamps
    end
    add_index :properties, :sign
  end unless table_exists?   :properties
end
