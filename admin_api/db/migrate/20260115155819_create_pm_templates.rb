class CreatePmTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_templates do |t|
      t.string :name
      t.text :description
      t.string :logo

      t.timestamps
    end
  end
end
