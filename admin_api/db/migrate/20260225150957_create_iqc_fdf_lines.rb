class CreateIqcFdfLines < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_fdf_lines do |t|
      t.references :fdf, foreign_key: { to_table: :iqc_fdfs }
      t.string :source
      t.string :batch_number
      t.string :yield_kl_t
      t.decimal :sample_weight_mg
      t.string :spectrum_id
      t.string :peak_area_ratio
      t.decimal :mass_fraction_percent
      t.decimal :specific_gravity
      t.decimal :mass_concentration_g_l
      t.decimal :suspension_powder_weight_g
      t.string :suspension_spectrum_id
      t.string :suspension_peak_area_ratio
      t.decimal :suspension_mass_fraction_percent
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
