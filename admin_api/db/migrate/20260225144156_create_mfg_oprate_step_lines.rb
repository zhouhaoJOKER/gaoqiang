class CreateMfgOprateStepLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_oprate_step_lines do |t|
      t.references :operate, foreign_key: { to_table: :mfg_oprates }
      t.string :step_time
      t.string :kettle_temp
      t.string :step_phase
      t.text :step_notes
      t.boolean :is_edit_note
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
