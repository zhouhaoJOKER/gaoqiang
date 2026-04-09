class CreateMatValues < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_values do |t|
      t.integer :user_id
      t.integer :updater_id
      t.integer :attribute_id
      t.string :name
      t.string :color
      t.decimal :extra_price, precision: 10, scale: 2
      t.float :sort

      t.timestamps
    end
    add_index :mat_values, :attribute_id
  end
end
