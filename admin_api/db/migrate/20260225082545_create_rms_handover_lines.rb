class CreateRmsHandoverLines < ActiveRecord::Migration[8.0]
  def change
    create_table :rms_handover_lines do |t|
      t.references :handover, foreign_key: { to_table: :rms_handovers }
      t.integer :sort
      t.string :name
      t.integer :product_id
      t.decimal :feeding_rate
      t.string :remark
      t.integer :user_id

      t.timestamps
    end
  end
end
