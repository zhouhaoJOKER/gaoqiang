class AddIndexToMenus < ActiveRecord::Migration[8.0]
  def change
    add_index :menus, [:parent_id, :menu_type, :sort, :created_at], name: "idx_parent_type_sort_created"
    add_index :menus, [:parent_id, :sort, :created_at], name: "idx_parent_sort_created"
    add_index :menus, [:parent_id, :id, :sort, :created_at], name: "idx_parent_id_sort_created"
  end
end
