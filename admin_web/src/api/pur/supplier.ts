import request from '@/utils/http'

export function listPurSupplierApi(params: any) {
  return request.get<any>({ url: '/pur/suppliers', params })
}

export function createPurSupplierApi(params: any) {
  return request.post<any>({ url: '/pur/suppliers', params })
}

export function viewPurSupplierApi(params: { id: string | number }) {
  return request.get<any>({ url: `/pur/suppliers/${params.id}`, params })
}

export function updatePurSupplierApi(id: string | number, params: any) {
  return request.put<any>({ url: `/pur/suppliers/${id}`, params })
}

export function deletePurSupplierApi(id: number) {
  return request.del<any>({ url: `/pur/suppliers/${id}` })
}

export function batchActionPurSupplierApi(params: any) {
  return request.post<any>({ url: '/pur/suppliers/batch_action', params })
}
