class CreatePmTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_tasks do |t|
      t.integer :project_id
      t.integer :stage_id
      t.integer :category_id
      t.integer :status_id
      t.integer :parent_id
      t.string :name
      t.string :py
      t.integer :priority_id
      t.integer :sort
      t.json :labels
      t.json :custom_fields
      t.datetime :due_at
      t.datetime :done_at
      t.boolean :is_star
      t.boolean :is_public
      t.boolean :is_done
      t.integer :executor_id
      t.integer :user_id
      t.integer :updater_id
      t.text :description
      t.decimal :plan_time, precision: 10, scale: 2
      t.decimal :real_time, precision: 10, scale: 2
      t.integer :progress
      t.string :ancestry

      t.timestamps
    end
    add_index :pm_tasks, :project_id
    add_index :pm_tasks, :parent_id
    add_index :pm_tasks, :stage_id
    add_index :pm_tasks, :ancestry
    
  end
end
