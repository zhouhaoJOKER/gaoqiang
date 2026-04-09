class CreateDocNumberRules < ActiveRecord::Migration[8.0]
  def change
    create_table :doc_number_rules do |t|
      t.string :key, null: false, comment: "唯一标识，如 fm_contracts"
      t.string :name, null: false, comment: "规则名称"
      t.string :format, null: false, comment: "格式模板，支持 {YYYY}{MM}{DD}{seq:4} 等占位符"
      t.integer :current_sequence, default: 0, null: false, comment: "当前序列号"
      t.string :reset_period, default: "none", comment: "序号重置周期: none/day/month/year"
      t.date :last_date, comment: "上次生成日期，用于按日/月/年重置"

      t.timestamps
    end
    add_index :doc_number_rules, :key, unique: true
  end
end
