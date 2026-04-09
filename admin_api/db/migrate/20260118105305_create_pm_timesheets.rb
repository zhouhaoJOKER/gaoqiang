class CreatePmTimesheets < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_timesheets do |t|
      t.integer :kind
      t.integer :project_id
      t.date :date
      t.integer :task_id
      t.decimal :time, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :pm_timesheets, :project_id
    add_index :pm_timesheets, :task_id
  end
end
