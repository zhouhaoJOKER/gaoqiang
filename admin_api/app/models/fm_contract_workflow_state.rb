# frozen_string_literal: true

class FmContractWorkflowState < ApplicationRecord
  self.table_name = "fm_contract_workflow_states"

  belongs_to :contract, class_name: "Fm::Contract", foreign_key: :contract_id

  validates :contract_id, :step_key, :status, presence: true
  validates :step_key, uniqueness: { scope: :contract_id }
  validates :status, inclusion: { in: %w[pending current completed failed] }

  def base_info
    {
      id: id,
      contract_id: contract_id,
      step_key: step_key,
      status: status,
      completed_at: completed_at,
      result: result,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end
