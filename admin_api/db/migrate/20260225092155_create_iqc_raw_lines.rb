class CreateIqcRawLines < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_raw_lines do |t|
      t.references :raw, foreign_key: { to_table: :iqc_raws }
      t.integer :sort
      t.string :content_percent
      t.decimal :m_value
      t.decimal :a_r_value
      t.string :x_percent

      t.timestamps
    end
  end
end
