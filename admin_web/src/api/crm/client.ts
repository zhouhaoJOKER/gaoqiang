import request from '@/utils/http'

export function listCrmClientApi(params: any) {
  return request.get<any>({ url: '/crm/clients', params })
}

export function createCrmClientApi(params: any) {
  return request.post<any>({ url: '/crm/clients', params })
}

export function viewCrmClientApi(params: any) {
  return request.get<any>({ url: `/crm/clients/${params.id}`, params })
}

export function updateCrmClientApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/clients/${id}`, params })
}

export function deleteCrmClientApi(id: number) {
  return request.del<any>({ url: `/crm/clients/${id}` })
}

export function batchActionCrmClientApi(params: any) {
  return request.post<any>({ url: '/crm/clients/batch_action', params })
}
