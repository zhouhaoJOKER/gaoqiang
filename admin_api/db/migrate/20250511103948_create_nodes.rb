class CreateNodes < ActiveRecord::Migration[8.0]
  def change
    create_table :nodes do |t|
      t.string :code
      t.string :name
      t.string :type
      t.integer :root_id
      t.integer :parent_id
      t.boolean :is_public
      t.string :file
      t.string :decrypt_file
      t.text :info
      t.string :remark
      t.integer :creater_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :nodes, :root_id
    add_index :nodes, :parent_id

  end
end
