class AddContentTypeToPmFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :pm_files, :content_type, :string
  end
end
