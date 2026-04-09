import request from '@/utils/http'

export function listCrmHandoverApi(params: any) {
  return request.get<any>({ url: '/crm/handovers', params })
}

export function createCrmHandoverApi(params: any) {
  return request.post<any>({ url: '/crm/handovers', params })
}

export function viewCrmHandoverApi(params: any) {
  return request.get<any>({ url: `/crm/handovers/${params.id}`, params })
}

export function updateCrmHandoverApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/handovers/${id}`, params })
}

export function deleteCrmHandoverApi(id: number) {
  return request.del<any>({ url: `/crm/handovers/${id}` })
}

export function batchActionCrmHandoverApi(params: any) {
  return request.post<any>({ url: '/crm/handovers/batch_action', params })
}

export function listCrmHandoverLineApi(params: any) {
  return request.get<any>({ url: '/crm/handover_lines', params })
}
