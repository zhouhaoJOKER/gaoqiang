import request from '@/utils/http'

export function listCrmOrderApi(params: any) {
  return request.get<any>({ url: '/crm/orders', params })
}

export function createCrmOrderApi(params: any) {
  return request.post<any>({ url: '/crm/orders', params })
}

export function viewCrmOrderApi(params: any) {
  return request.get<any>({ url: `/crm/orders/${params.id}`, params })
}

export function updateCrmOrderApi(id: string | number, params: any) {
  return request.put<any>({ url: `/crm/orders/${id}`, params })
}

/** 订单主档附件：上传/替换 ActiveStorage `file` */
export function uploadCrmOrderFileApi(id: string | number, file: File) {
  const fd = new FormData()
  fd.append('file', file)
  return request.put<any>({ url: `/crm/orders/${id}`, data: fd })
}

export function deleteCrmOrderApi(id: string | number) {
  return request.del<any>({ url: `/crm/orders/${id}` })
}

export function batchActionCrmOrderApi(params: any) {
  return request.post<any>({ url: '/crm/orders/batch_action', params })
}

export function listCrmOrderLineApi(params: any) {
  return request.get<any>({ url: '/crm/order_lines', params })
}

/** 内跟单：订单明细 + 订单头信息，分页 */
export function listCrmInternalTrackingApi(params: any) {
  return request.get<any>({ url: '/crm/order_lines/internal_tracking', params })
}

/** 内跟单：按明细行 id 获取详情（复用 internal_tracking 列表过滤） */
export function viewCrmInternalTrackingByIdApi(id: string | number) {
  return request.get<any>({
    url: '/crm/order_lines/internal_tracking',
    params: {
      page: 1,
      per_page: 1,
      // ransack 支持的过滤字段：id_eq
      'q[id_eq]': id
    }
  })
}

/** 内跟单详情：按订单明细行 id 获取所有字段（来自 /crm/order_lines/:id） */
export function viewCrmOrderLineByIdApi(id: string | number) {
  return request.get<any>({
    url: `/crm/order_lines/${id}`
  })
}

/** 更新明细行（JSON，非文件上传） */
export function updateCrmOrderLineDataApi(id: string | number, params: Record<string, unknown>) {
  return request.put<any>({ url: `/crm/order_lines/${id}`, data: params })
}

/** 订单明细产品图文：上传 ActiveStorage 附件 */
export function uploadCrmOrderLineFileApi(id: string | number, file: File) {
  const fd = new FormData()
  fd.append('file', file)
  return request.put<any>({ url: `/crm/order_lines/${id}`, data: fd })
}
