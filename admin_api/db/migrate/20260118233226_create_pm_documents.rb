class CreatePmDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_documents do |t|
      t.integer :project_id
      t.integer :parent_id
      t.integer :kind
      t.string :name
      t.string :py
      t.text :content
      t.integer :user_id
      t.integer :updater_id
      t.boolean :is_public
      t.string :ancestry

      t.timestamps
    end
    add_index :pm_documents, :project_id
    add_index :pm_documents, :ancestry
  end
end
