class AddRecordIdToLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :logs, :record_id, :integer unless column_exists? :logs, :record_id
    add_column :logs, :record_type, :string unless column_exists? :logs, :record_type
    add_index :logs, [:record_id, :record_type] unless index_exists? :logs, [:record_id, :record_type]
  end
end
