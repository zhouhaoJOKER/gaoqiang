class CreatePmPortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_portfolios do |t|
      t.string :code
      t.string :name
      t.integer :status_id
      t.date :start_date
      t.date :end_date
      t.boolean :is_star
      t.integer :manager_id
      t.text :description
      t.json :degree
      t.json :labels
      t.json :custom_fields
      t.integer :user_id
      t.integer :updater_id
      t.integer :company_id

      t.timestamps
    end
    add_index :pm_portfolios, :company_id
  end
end
