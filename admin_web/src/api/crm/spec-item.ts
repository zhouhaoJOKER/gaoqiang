import request from '@/utils/http'

export function listCrmSpecItemApi(params: any) {
  return request.get<any>({ url: '/crm/spec_items', params })
}

export function createCrmSpecItemApi(params: any) {
  return request.post<any>({ url: '/crm/spec_items', params })
}

export function viewCrmSpecItemApi(params: any) {
  return request.get<any>({ url: `/crm/spec_items/${params.id}`, params })
}

export function updateCrmSpecItemApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/spec_items/${id}`, params })
}

export function deleteCrmSpecItemApi(id: number) {
  return request.del<any>({ url: `/crm/spec_items/${id}` })
}

export function batchActionCrmSpecItemApi(params: any) {
  return request.post<any>({ url: '/crm/spec_items/batch_action', params })
}
