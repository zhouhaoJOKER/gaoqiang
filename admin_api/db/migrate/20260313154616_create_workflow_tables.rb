# frozen_string_literal: true

class CreateWorkflowTables < ActiveRecord::Migration[8.0]
  def change
    # 流程模板
    create_table :workflow_templates, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", if_not_exists: true do |t|
      t.string :code, null: false, comment: "模板编码，如 contract_full"
      t.string :name, null: false, comment: "模板名称"
      t.text :description, comment: "描述"
      t.json :main_step_keys, comment: "主流程节点顺序"
      t.boolean :is_default, default: false, comment: "是否默认模板"
      t.integer :sort, default: 0
      t.boolean :is_active, default: true, comment: "是否启用"
      t.integer :user_id
      t.timestamps
    end
    add_index :workflow_templates, :code, unique: true, if_not_exists: true

    # 流程节点
    create_table :workflow_nodes, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", if_not_exists: true do |t|
      t.references :template, null: false, foreign_key: { to_table: :workflow_templates }, index: true
      t.string :key, null: false, comment: "节点标识，如 order、formula"
      t.string :label, null: false, comment: "节点名称"
      t.text :description, comment: "节点描述"
      t.integer :position_x, default: 0, comment: "画布 x 坐标"
      t.integer :position_y, default: 0, comment: "画布 y 坐标"
      t.integer :sort, default: 0
      t.boolean :has_result_options, default: false, comment: "是否有分支结果"
      t.string :node_type, default: "workflow", comment: "节点类型"
      t.timestamps
    end
    add_index :workflow_nodes, [:template_id, :key], unique: true, if_not_exists: true

    # 节点结果选项（分支）
    create_table :workflow_node_results, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", if_not_exists: true do |t|
      t.references :template, null: false, foreign_key: { to_table: :workflow_templates }, index: true
      t.string :node_key, null: false, comment: "所属节点 key"
      t.string :result_value, null: false, comment: "结果值"
      t.string :result_label, comment: "结果标签"
      t.string :target_key, comment: "跳转的节点 key"
      t.integer :sort, default: 0
      t.timestamps
    end
    add_index :workflow_node_results, [:template_id, :node_key, :result_value], unique: true, name: "idx_wf_node_results_uniq", if_not_exists: true

    # 流程边
    create_table :workflow_edges, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", if_not_exists: true do |t|
      t.references :template, null: false, foreign_key: { to_table: :workflow_templates }, index: true
      t.string :source_key, null: false, comment: "源节点 key"
      t.string :target_key, null: false, comment: "目标节点 key"
      t.string :label, comment: "边的标签"
      t.string :result_value, comment: "条件结果"
      t.integer :sort, default: 0
      t.timestamps
    end
    add_index :workflow_edges, [:template_id, :source_key, :target_key], name: "idx_wf_edges_template_source_target", if_not_exists: true

    # 合同表增加流程模板关联
    add_column :fm_contracts, :workflow_template_id, :bigint, comment: "关联流程模板" unless column_exists?(:fm_contracts, :workflow_template_id)
    add_index :fm_contracts, :workflow_template_id, if_not_exists: true

  end
end
