# frozen_string_literal: true

class CreateFmContractWorkflowLogsAndStates < ActiveRecord::Migration[8.0]
  def change
    create_table :fm_contract_workflow_logs, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint :contract_id, null: false, comment: "关联合同"
      t.string :step_key, null: false, comment: "节点标识"
      t.string :step_label, comment: "节点名称"
      t.datetime :operated_at, null: false, comment: "操作时间"
      t.integer :operator_id, comment: "操作人 ID"
      t.string :operator_name, comment: "操作人姓名"
      t.text :action, comment: "操作/备注内容"
      t.string :result, comment: "节点结果"
      t.json :result_extra, comment: "扩展结果"
      t.integer :sort, default: 0
      t.integer :user_id
      t.timestamps
    end
    add_index :fm_contract_workflow_logs, :contract_id
    add_index :fm_contract_workflow_logs, :operated_at

    create_table :fm_contract_workflow_states, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci" do |t|
      t.bigint :contract_id, null: false, comment: "关联合同"
      t.string :step_key, null: false, comment: "节点标识"
      t.string :status, null: false, default: "pending", comment: "pending/current/completed/failed"
      t.datetime :completed_at, comment: "完成时间"
      t.string :result, comment: "该节点最终结果"
      t.integer :user_id
      t.timestamps
    end
    add_index :fm_contract_workflow_states, [:contract_id, :step_key], unique: true, name: "idx_wf_states_contract_step"
  end
end
