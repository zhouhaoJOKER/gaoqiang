class CreateMfgOprateLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_oprate_lines do |t|
      t.references :operate, foreign_key: { to_table: :mfg_oprates }
      t.integer :sort
      t.string :name
      t.string :batch_number
      t.decimal :qty_kg
      t.integer :user_id

      t.timestamps
    end
  end
end
