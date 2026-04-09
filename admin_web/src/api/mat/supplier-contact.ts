import request from '@/utils/http'

export function listMatSupplierContactApi(params: any) {
  return request.get<any>({ url: '/pur/contacts', params })
}

export function createMatSupplierContactApi(params: {
  supplier_id: string | number
  name: string
  phone?: string
  fax?: string
}) {
  return request.post<any>({ url: '/pur/contacts', params })
}

export function viewMatSupplierContactApi(params: { id: string | number }) {
  return request.get<any>({ url: `/pur/contacts/${params.id}`, params })
}

export function updateMatSupplierContactApi(id: string, params: any) {
  return request.put<any>({ url: `/pur/contacts/${id}`, params })
}

export function deleteMatSupplierContactApi(id: number) {
  return request.del<any>({ url: `/pur/contacts/${id}` })
}
