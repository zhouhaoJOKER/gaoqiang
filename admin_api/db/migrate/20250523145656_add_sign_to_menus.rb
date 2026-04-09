class AddSignToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :signs, :string
    add_column :menus, :folder_id, :integer
    
  end
end
