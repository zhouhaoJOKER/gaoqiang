import request from '@/utils/http'

export function listCrmQuotationApi(params: any) {
  return request.get<any>({ url: '/crm/quotations', params })
}

export function createCrmQuotationApi(params: any) {
  return request.post<any>({ url: '/crm/quotations', params })
}

export function viewCrmQuotationApi(params: any) {
  return request.get<any>({ url: `/crm/quotations/${params.id}`, params })
}

export function updateCrmQuotationApi(id: string, params: any) {
  return request.put<any>({ url: `/crm/quotations/${id}`, params })
}

export function deleteCrmQuotationApi(id: number) {
  return request.del<any>({ url: `/crm/quotations/${id}` })
}

export function batchActionCrmQuotationApi(params: any) {
  return request.post<any>({ url: '/crm/quotations/batch_action', params })
}

export function listCrmQuotationLineApi(params: any) {
  return request.get<any>({ url: '/crm/quotation_lines', params })
}
