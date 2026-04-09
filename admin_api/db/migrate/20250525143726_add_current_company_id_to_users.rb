class AddCurrentCompanyIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_company_id, :integer
  end
end
