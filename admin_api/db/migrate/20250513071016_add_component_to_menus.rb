class AddComponentToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :component, :string
  end
end
