# frozen_string_literal: true

class FmContractWorkflowLog < ApplicationRecord
  self.table_name = "fm_contract_workflow_logs"

  belongs_to :contract, class_name: "Fm::Contract", foreign_key: :contract_id
  belongs_to :operator, class_name: "User", foreign_key: :operator_id, optional: true

  validates :contract_id, :step_key, :operated_at, presence: true

  def base_info
    {
      id: id,
      contract_id: contract_id,
      step_key: step_key,
      step_label: step_label,
      operated_at: operated_at,
      operator_id: operator_id,
      operator_name: operator_name,
      action: action,
      result: result,
      result_extra: result_extra,
      sort: sort,
      created_at: created_at,
      updated_at: updated_at,
    }
  end
end
