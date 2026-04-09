class ChangeMenusNameToTitle < ActiveRecord::Migration[8.0]
  def change
    rename_column :menus, :label, :title
    remove_column :menus, :roles
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
