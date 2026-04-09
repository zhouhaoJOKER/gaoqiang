class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    
    drop_table :companies  if table_exists? 'companies'
    create_table :companies do |t|
      t.string :logo
      t.integer :parent_id
      t.string :abbr
      t.string :name
      t.string :credit_code
      t.string :legal_name
      t.integer :status_id
      t.date :reg_date
      t.string :reg_capital
      t.string :reg_address
      t.integer :company_type_id
      t.string :contact
      t.string :email
      t.text :business_scope
      t.integer :industry_id
      t.string :business_reg_number
      t.string :business_term
      t.date :approval_date
      t.integer :region_id
      t.string :organization_code
      t.integer :user_id
      t.string :py

      t.timestamps
      t.index :parent_id
      t.index :status_id
      t.index :company_type_id
      t.index :industry_id
      t.index :region_id
      t.index :user_id
      t.index [:name, :py, :credit_code], unique: true
    end
  end
end
