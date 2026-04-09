class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :code
      t.string :name
      t.integer :category
      t.string :act
      t.string :ctrl
      t.string :sign
      t.boolean :core
      t.integer :user_id

      t.timestamps
    end
    add_index :permissions, :user_id

  end
end
