class CreatePmProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_projects do |t|
      t.integer :portfolio_id
      t.integer :parent_id
      t.string :code
      t.string :name
      t.string :py
      t.string :pinyin
      t.string :logo
      t.integer :status_id
      t.integer :source_id
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
      t.boolean :is_public
      t.boolean :is_archived
      t.boolean :is_suspended
      t.datetime :suspend_at
      t.integer :suspender_id
      t.string :ancestry

      t.timestamps
    end
    add_index :pm_projects, :company_id
    add_index :pm_projects, :parent_id
    add_index :pm_projects, :ancestry
  end
end
