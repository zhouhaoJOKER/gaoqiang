class CreateMatCombos < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_combos do |t|
      t.integer :user_id
      t.integer :updater_id
      t.integer :company_id
      t.string :name
      t.integer :min
      t.integer :max
      t.decimal :price, precision: 10, scale: 2
      t.integer :discount
      t.text :description

      t.timestamps
    end
    add_index :mat_combos, :company_id
  end
end
