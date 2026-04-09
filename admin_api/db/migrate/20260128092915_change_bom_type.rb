class ChangeBomType < ActiveRecord::Migration[8.0]
  def change
    remove_column :mfg_boms, :type, :string
    add_column :mfg_boms, :type_id, :integer
    add_index :mfg_boms, :type_id
  end
end
