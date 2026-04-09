class CreateMenus < ActiveRecord::Migration[8.0]
  def change
    create_table :menus do |t|
      t.string :path
      t.string :name
      t.string :redirect
      t.string :icon
      t.string :title
      t.string :is_link
      t.boolean :is_hide, :default => false
      t.boolean :is_full, :default => false
      t.boolean :is_affix, :default => false
      t.boolean :is_keep_alive, :default => false
      t.string :active_menu
      t.integer :sort
      t.string :remark
      t.integer :parent_id
      t.integer :user_id

      t.timestamps
    end
  end
end
