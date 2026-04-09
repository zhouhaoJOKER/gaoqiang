import request from '@/utils/http'

// ========== 流程模板 ==========
export function listWorkflowTemplatesApi(params?: Record<string, any>) {
  return request.get<any>({ url: '/workflow/templates', params })
}

export function viewWorkflowTemplateApi(params: { id: string | number }) {
  return request.get<any>({ url: `/workflow/templates/${params.id}`, params })
}

export function createWorkflowTemplateApi(params: Record<string, any>) {
  return request.post<any>({ url: '/workflow/templates', params })
}

export function updateWorkflowTemplateApi(id: string | number, params: Record<string, any>) {
  return request.put<any>({ url: `/workflow/templates/${id}`, params })
}

export function deleteWorkflowTemplateApi(id: string | number) {
  return request.del<any>({ url: `/workflow/templates/${id}` })
}

// ========== 流程节点 ==========
export function listWorkflowNodesApi(templateId: string | number, params?: Record<string, any>) {
  return request.get<any>({ url: `/workflow/templates/${templateId}/nodes`, params })
}

export function createWorkflowNodeApi(templateId: string | number, params: Record<string, any>) {
  return request.post<any>({ url: `/workflow/templates/${templateId}/nodes`, params })
}

export function updateWorkflowNodeApi(
  templateId: string | number,
  nodeKey: string,
  params: Record<string, any>
) {
  return request.put<any>({
    url: `/workflow/templates/${templateId}/nodes/${encodeURIComponent(nodeKey)}`,
    params
  })
}

export function deleteWorkflowNodeApi(templateId: string | number, nodeKey: string) {
  return request.del<any>({
    url: `/workflow/templates/${templateId}/nodes/${encodeURIComponent(nodeKey)}`
  })
}

// ========== 流程边 ==========
export function listWorkflowEdgesApi(templateId: string | number, params?: Record<string, any>) {
  return request.get<any>({ url: `/workflow/templates/${templateId}/edges`, params })
}

export function createWorkflowEdgeApi(templateId: string | number, params: Record<string, any>) {
  return request.post<any>({ url: `/workflow/templates/${templateId}/edges`, params })
}

export function updateWorkflowEdgeApi(
  templateId: string | number,
  sourceKey: string,
  targetKey: string,
  params: Record<string, any>
) {
  return request.put<any>({
    url: `/workflow/templates/${templateId}/edges/${encodeURIComponent(sourceKey)}/${encodeURIComponent(targetKey)}`,
    params
  })
}

export function deleteWorkflowEdgeApi(
  templateId: string | number,
  sourceKey: string,
  targetKey: string,
  resultValue?: string
) {
  let url = `/workflow/templates/${templateId}/edges/${encodeURIComponent(sourceKey)}/${encodeURIComponent(targetKey)}`
  if (resultValue) {
    url += `?result_value=${encodeURIComponent(resultValue)}`
  }
  return request.del<any>({ url })
}

// ========== 节点结果选项（分支配置）==========
export function listWorkflowNodeResultsApi(
  templateId: string | number,
  params?: Record<string, any>
) {
  return request.get<any>({ url: `/workflow/templates/${templateId}/node_results`, params })
}

export function createWorkflowNodeResultApi(
  templateId: string | number,
  params: Record<string, any>
) {
  return request.post<any>({ url: `/workflow/templates/${templateId}/node_results`, params })
}

export function updateWorkflowNodeResultApi(
  templateId: string | number,
  id: string | number,
  params: Record<string, any>
) {
  return request.put<any>({
    url: `/workflow/templates/${templateId}/node_results/${id}`,
    params
  })
}

export function deleteWorkflowNodeResultApi(templateId: string | number, id: string | number) {
  return request.del<any>({
    url: `/workflow/templates/${templateId}/node_results/${id}`
  })
}

// ========== 合同流程（定义、日志、状态）==========
/** 获取合同使用的流程定义（nodes + edges + node_results，供前端 Vue Flow 使用） */
export function getContractWorkflowDefinitionApi(contractId: string | number) {
  return request.get<any>({ url: `/fm/contracts/${contractId}/workflow_definition` })
}

/** 获取合同流程日志列表 */
export function listContractWorkflowLogsApi(
  contractId: string | number,
  params?: Record<string, any>
) {
  return request.get<any>({ url: `/fm/contracts/${contractId}/workflow_logs`, params })
}

/** 创建合同流程日志（节点确认时调用） */
export function createContractWorkflowLogApi(
  contractId: string | number,
  params: {
    step_key: string
    step_label: string
    operated_at?: string
    operator_id?: number
    operator_name?: string
    action?: string
    result?: string
    result_extra?: Record<string, any>
  }
) {
  return request.post<any>({ url: `/fm/contracts/${contractId}/workflow_logs`, params })
}

/** 获取合同流程状态（各节点 pending/current/completed） */
export function listContractWorkflowStatesApi(contractId: string | number) {
  return request.get<any>({ url: `/fm/contracts/${contractId}/workflow_states` })
}

/** 批量更新合同流程状态（节点确认后调用） */
export function updateContractWorkflowStatesApi(
  contractId: string | number,
  params: {
    states: Array<{ step_key: string; status: string; result?: string; completed_at?: string }>
  }
) {
  return request.put<any>({ url: `/fm/contracts/${contractId}/workflow_states`, params })
}
