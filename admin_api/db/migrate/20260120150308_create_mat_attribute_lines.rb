class CreateMatAttributeLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_attribute_lines do |t|
      t.integer :user_id
      t.integer :product_id
      t.integer :attribute_id
      t.string :name
      t.json :values
      t.json :value_ids
      t.float :sort

      t.timestamps
    end
    add_index :mat_attribute_lines, :product_id
    add_index :mat_attribute_lines, :attribute_id
  end
end
