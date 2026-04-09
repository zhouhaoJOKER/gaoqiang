class CreateMfgPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_plans do |t|
      t.string :plan_title
      t.date :week_start_date
      t.date :week_end_date
      t.integer :workshop_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
