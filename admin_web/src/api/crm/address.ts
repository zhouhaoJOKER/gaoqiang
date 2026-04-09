import request from '@/utils/http'

export function listCrmAddressApi(params: any) {
  return request.get<any>({ url: '/crm/addresses', params })
}

export function createCrmAddressApi(params: any) {
  return request.post<any>({ url: '/crm/addresses', params })
}

export function viewCrmAddressApi(params: any) {
  return request.get<any>({ url: `/crm/addresses/${params.id}`, params })
}

export function updateCrmAddressApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/addresses/${id}`, params })
}

export function deleteCrmAddressApi(id: number) {
  return request.del<any>({ url: `/crm/addresses/${id}` })
}

export function batchActionCrmAddressApi(params: any) {
  return request.post<any>({ url: '/crm/addresses/batch_action', params })
}
