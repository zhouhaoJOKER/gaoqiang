import request from '@/utils/http'

export function listCrmInvoiceApi(params: any) {
  return request.get<any>({ url: '/crm/invoices', params })
}

export function createCrmInvoiceApi(params: any) {
  return request.post<any>({ url: '/crm/invoices', params })
}

export function viewCrmInvoiceApi(params: any) {
  return request.get<any>({ url: `/crm/invoices/${params.id}`, params })
}

export function updateCrmInvoiceApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/invoices/${id}`, params })
}

export function deleteCrmInvoiceApi(id: number) {
  return request.del<any>({ url: `/crm/invoices/${id}` })
}

export function batchActionCrmInvoiceApi(params: any) {
  return request.post<any>({ url: '/crm/invoices/batch_action', params })
}
