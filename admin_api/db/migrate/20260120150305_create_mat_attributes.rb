class CreateMatAttributes < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_attributes do |t|
      t.integer :user_id
      t.integer :updater_id
      t.integer :company_id
      t.string :name
      t.string :py
      t.boolean :is_variant
      t.string :display_type
      t.float :sort

      t.timestamps
    end
    add_index :mat_attributes, :company_id
  end
end
