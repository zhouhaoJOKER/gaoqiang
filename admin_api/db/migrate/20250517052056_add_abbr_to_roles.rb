class AddAbbrToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :abbr, :string
  end
end
