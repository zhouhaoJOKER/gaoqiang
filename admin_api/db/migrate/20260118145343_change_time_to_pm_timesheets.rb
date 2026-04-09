class ChangeTimeToPmTimesheets < ActiveRecord::Migration[8.0]
  def change
    change_column :pm_timesheets, :time, :decimal, precision: 10, scale: 2
  end
end
