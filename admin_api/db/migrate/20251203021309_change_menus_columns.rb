class ChangeMenusColumns < ActiveRecord::Migration[8.0]
  def change

    rename_column("menus", "title","label")
    rename_column("menus", "redirect","link")
    rename_column("menus", "is_full","is_full_page")
    rename_column("menus", "is_keep_alive","keep_alive")
    rename_column("menus", "active_menu","active_path")
    rename_column("menus", "perms","roles")
    #
    add_column :menus, :is_iframe, :boolean, default: false unless column_exists? :menus, :is_iframe
    add_column :menus, :is_enable, :boolean, default: true unless column_exists? :menus, :is_enable
    add_column :menus, :show_badge, :boolean, default: false unless column_exists? :menus, :show_badge
    add_column :menus, :fixed_tab, :boolean, default: false unless column_exists? :menus, :fixed_tab
    add_column :menus, :is_hide_tab, :boolean, default: false unless column_exists? :menus, :is_hide_tab
    add_column :menus, :show_text_badge, :string, default: '' unless column_exists? :menus, :show_text_badge
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
