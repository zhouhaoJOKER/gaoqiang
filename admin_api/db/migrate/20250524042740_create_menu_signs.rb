class CreateMenuSigns < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_signs do |t|
      t.integer :menu_id
      t.string :sign

      t.timestamps
    end
    add_index :menu_signs, :menu_id
  end
end
