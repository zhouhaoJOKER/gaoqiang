class AddDescriptionToPmTimesheets < ActiveRecord::Migration[8.0]
  def change
    add_column :pm_timesheets, :description, :string
  end
end
