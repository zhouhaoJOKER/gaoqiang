class CreateMfgBomLosses < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_bom_losses do |t|
      t.integer :bom_line_id
      t.string :loss_mode
      t.decimal :loss_value, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_bom_losses, :bom_line_id
  end
end
