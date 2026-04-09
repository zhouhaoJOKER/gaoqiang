class AddAncestryToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :ancestry, :string unless column_exists? :menus, :ancestry
    add_index :menus, :ancestry unless index_exists? :menus, :ancestry
    
  end
end
