class ChangeRolesRolesToCompanyIds < ActiveRecord::Migration[8.0]
  def change
    rename_column :roles, :roles, :company_ids
    rename_column :roles, :abbr, :sign
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
