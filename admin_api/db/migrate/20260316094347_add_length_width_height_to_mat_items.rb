class AddLengthWidthHeightToMatItems < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_items, :length, :decimal, precision: 12, scale: 2, default: "0.0"
    add_column :mat_items, :width, :decimal, precision: 12, scale: 2, default: "0.0"
    add_column :mat_items, :height, :decimal, precision: 12, scale: 2, default: "0.0"
  end
end
