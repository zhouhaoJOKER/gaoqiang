class CreatePmStages < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_stages do |t|
      t.integer :project_id
      t.string :name
      t.integer :sort
      t.integer :task_count
      t.boolean :is_archived
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :pm_stages, :project_id
  end
end
