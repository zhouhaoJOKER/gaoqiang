class CreateMfgBatchingLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_batching_lines do |t|
      t.references :batching, foreign_key: { to_table: :mfg_batchings }
      t.integer :sort
      t.string :category
      t.string :name
      t.integer :product_id
      t.string :batch_number
      t.decimal :qty_kg
      t.decimal :content_percent
      t.decimal :adjusted_qty_kg
      t.string :remark
      t.integer :user_id

      t.timestamps
    end
  end
end
