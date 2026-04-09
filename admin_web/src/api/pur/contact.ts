import request from '@/utils/http'

export function listPurContactApi(params: any) {
  return request.get<any>({ url: '/pur/contacts', params })
}

export function createPurContactApi(params: any) {
  return request.post<any>({ url: '/pur/contacts', params })
}

export function viewPurContactApi(params: { id: string | number }) {
  return request.get<any>({ url: `/pur/contacts/${params.id}`, params })
}

export function updatePurContactApi(id: string | number, params: any) {
  return request.put<any>({ url: `/pur/contacts/${id}`, params })
}

export function deletePurContactApi(id: number) {
  return request.del<any>({ url: `/pur/contacts/${id}` })
}

export function batchActionPurContactApi(params: any) {
  return request.post<any>({ url: '/pur/contacts/batch_action', params })
}
