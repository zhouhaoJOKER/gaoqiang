class AddIsAffixToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :is_affix, :boolean  unless column_exists? :menus, :is_affix
  end
end
