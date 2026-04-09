import request from '@/utils/http'

export function listCrmPreOrderApi(params: any) {
  return request.get<any>({ url: '/crm/pre_orders', params })
}

export function viewCrmPreOrderApi(params: any) {
  return request.get<any>({ url: `/crm/pre_orders/${params.id}`, params })
}

export function updateCrmPreOrderApi(id: string | number, params: any) {
  return request.put<any>({ url: `/crm/pre_orders/${id}`, params })
}

export function deleteCrmPreOrderApi(id: string | number) {
  return request.del<any>({ url: `/crm/pre_orders/${id}` })
}

export function convertCrmPreOrderToOrderApi(id: string | number, params: any) {
  return request.post<any>({ url: `/crm/pre_orders/${id}/convert_to_order`, params })
}
