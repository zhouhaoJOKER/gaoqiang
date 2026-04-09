class ChangeDepartmentsStatus < ActiveRecord::Migration[8.0]
  def change
    change_column :departments, :status, :boolean, :default => true unless column_exists? :departments, :status
    #Ex:- :default =>''
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
