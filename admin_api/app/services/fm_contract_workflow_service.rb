# frozen_string_literal: true

# 合同创建时初始化流程记录：生成首条日志（订单节点）及所有节点状态
class FmContractWorkflowService
  MAIN_STEP_KEYS = %w[
    order formula purchase warehouse inspect plan schedule formulate
    test_qc pack_setup first_bottle packing sampling ship
  ].freeze

  class << self
    # 合同创建成功后调用，初始化流程记录
    def init_workflow_for_contract(contract, operator: nil)
      template = contract.workflow_template_id.present? ?
        ::Workflow::Template.find_by(id: contract.workflow_template_id) :
        ::Workflow::Template.default_template
      return unless template

      nodes = template.nodes.order(:sort)
      step_keys = nodes.any? ? nodes.pluck(:key) : MAIN_STEP_KEYS
      first_key = step_keys.first
      return if first_key.blank?

      now = Time.current
      operator_id = operator&.id
      operator_name = operator&.name || "系统"

      # 1. 创建首条流程日志（订单节点）
      FmContractWorkflowLog.create!(
        contract_id: contract.id,
        step_key: first_key,
        step_label: nodes.find { |n| n.key == first_key }&.label || first_key,
        operated_at: now,
        operator_id: operator_id,
        operator_name: operator_name,
        action: "创建合同，合同编号 #{contract.code}",
        result: nil,
        result_extra: nil,
        sort: 0,
        user_id: operator_id
      )

      # 2. 创建各节点状态
      step_keys.each_with_index do |key, idx|
        status = idx == 0 ? "current" : "pending"
        FmContractWorkflowState.find_or_create_by!(contract_id: contract.id, step_key: key) do |s|
          s.status = status
          s.completed_at = (idx == 0 ? now : nil)
          s.user_id = operator_id
        end
      end
    end

    # 流程推进：完成当前节点，根据 result 确定下一节点并更新状态
    def advance_state(contract, step_key, result, operator: nil)
      template = contract.workflow_template || ::Workflow::Template.default_template
      return unless template

      now = Time.current
      operator_id = operator&.id

      # 1. 当前节点 -> completed
      state = contract.workflow_states.find_by(step_key: step_key)
      if state
        state.update!(status: "completed", completed_at: now, result: result, user_id: operator_id)
      end

      # 2. 确定下一节点
      next_key = nil
      node_result = template.node_results.find_by(node_key: step_key, result_value: result)
      if node_result&.target_key.present?
        next_key = node_result.target_key
      else
        edge = template.edges.find_by(source_key: step_key)
        next_key = edge&.target_key if edge
      end

      # 3. 下一节点 -> current（若存在且在主流程中）
      if next_key.present?
        next_state = contract.workflow_states.find_or_initialize_by(step_key: next_key)
        next_state.status = "current"
        next_state.completed_at = nil
        next_state.result = nil
        next_state.user_id = operator_id
        next_state.save!
      end
    end

    # 为订购合同追加一条流程操作日志（供交接单、配方交接单、采购合同等创建时调用）
    # 若该合同尚未初始化流程，则先初始化再追加
    def append_log(fm_contract_id, step_key:, step_label: nil, action:, operator: nil)
      return if fm_contract_id.blank?
      contract = ::Fm::Contract.find_by(id: fm_contract_id)
      return unless contract

      ensure_workflow_inited(contract, operator: operator)

      now = Time.current
      operator_id = operator&.id
      operator_name = operator&.name || "系统"
      template = contract.workflow_template || ::Workflow::Template.default_template
      step_label = step_label.presence || template&.nodes&.find_by(key: step_key)&.label || step_key

      sort = (contract.workflow_logs.maximum(:sort) || -1) + 1
      FmContractWorkflowLog.create!(
        contract_id: contract.id,
        step_key: step_key,
        step_label: step_label,
        operated_at: now,
        operator_id: operator_id,
        operator_name: operator_name,
        action: action,
        result: nil,
        result_extra: nil,
        sort: sort,
        user_id: operator_id
      )
    end

    # 若合同尚无流程状态，则初始化（避免漏初始化）
    def ensure_workflow_inited(contract, operator: nil)
      return if contract.workflow_states.exists?
      init_workflow_for_contract(contract, operator: operator)
    end
  end
end
