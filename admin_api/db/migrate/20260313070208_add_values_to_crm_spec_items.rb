class AddValuesToCrmSpecItems < ActiveRecord::Migration[8.0]
  def change
    add_column :crm_spec_items, :values, :json
  end
end
