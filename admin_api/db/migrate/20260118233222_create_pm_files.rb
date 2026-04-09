class CreatePmFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_files do |t|
      t.integer :project_id
      t.integer :parent_id
      t.string :py
      t.string :name
      t.integer :file_size
      t.string :color
      t.integer :user_id
      t.integer :updater_id
      t.integer :file_count
      t.boolean :is_public
      t.integer :kind
      t.string :ancestry

      t.timestamps
    end
    add_index :pm_files, :project_id
    add_index :pm_files, :ancestry
  end
end
