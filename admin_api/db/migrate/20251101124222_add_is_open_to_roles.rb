class AddIsOpenToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :is_open, :boolean, :default => true  unless column_exists? :roles, :is_open
    #Ex:- :default =>''
    add_column :roles, :menu_ids, :text unless column_exists? :roles, :menu_ids
    add_column :roles, :company_id, :integer  unless column_exists? :roles, :company_id
  end
end
