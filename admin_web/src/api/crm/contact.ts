import request from '@/utils/http'

export function listCrmContactApi(params: any) {
  return request.get<any>({ url: '/crm/contacts', params })
}

export function createCrmContactApi(params: any) {
  return request.post<any>({ url: '/crm/contacts', params })
}

export function viewCrmContactApi(params: any) {
  return request.get<any>({ url: `/crm/contacts/${params.id}`, params })
}

export function updateCrmContactApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/contacts/${id}`, params })
}

export function deleteCrmContactApi(id: number) {
  return request.del<any>({ url: `/crm/contacts/${id}` })
}

export function batchActionCrmContactApi(params: any) {
  return request.post<any>({ url: '/crm/contacts/batch_action', params })
}
