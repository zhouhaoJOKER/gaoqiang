class CreatePurContractWorkflowLogsAndStates < ActiveRecord::Migration[8.0]
  def change
    create_table :pur_contract_workflow_logs_and_states do |t|
      t.timestamps
    end
  end
end
