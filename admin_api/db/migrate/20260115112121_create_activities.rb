class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.integer :status_id
      t.text :content
      t.integer :parent_id
      t.integer :record_id
      t.string :record_type
      t.integer :user_id
      t.json :mention_ids
      t.json :file_urls

      t.datetime "created_at", null: false

      t.index [:record_id, :record_type], name: "index_activities_on_record"
    end
  end
end
