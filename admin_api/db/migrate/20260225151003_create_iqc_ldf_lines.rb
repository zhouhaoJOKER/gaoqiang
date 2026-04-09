class CreateIqcLdfLines < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_ldf_lines do |t|
      t.references :ldf, foreign_key: { to_table: :iqc_ldfs }
      t.date :inspection_date
      t.string :source
      t.string :batch_number
      t.decimal :ph_value
      t.decimal :specific_gravity_g_ml
      t.decimal :moisture_percent
      t.decimal :flash_point_c
      t.string :viscosity
      t.string :dispersion_stability_20_200
      t.string :foam_retention_ml
      t.string :pourability
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
