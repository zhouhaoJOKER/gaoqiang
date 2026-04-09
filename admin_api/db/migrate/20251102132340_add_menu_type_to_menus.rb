class AddMenuTypeToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :menu_type, :string unless column_exists? :menus, :menu_type
    add_column :menus, :perms, :string unless column_exists? :menus, :perms
  end
end
