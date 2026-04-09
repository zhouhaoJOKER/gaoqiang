import request from '@/utils/http'

// 获取生产订单列表
export function listMfgOrderApi(params: any) {
  return request.get<any>({
    url: '/mfg/orders',
    params
  })
}

// 创建生产订单
export function createMfgOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/orders',
    params
  })
}

// 访问生产订单详情
export function viewMfgOrderApi(params: any) {
  return request.get<any>({
    url: `/mfg/orders/${params.id}`,
    params
  })
}

// 生产订单更新
export function updateMfgOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/orders/${id}`,
    params
  })
}

// 生产订单删除
export function deleteMfgOrderApi(id: number) {
  return request.del<any>({
    url: `/mfg/orders/${id}`
  })
}

// 批量操作生产订单
export function batchActionMfgOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/orders/batch_action',
    params
  })
}

// 获取生产订单明细列表
export function listMfgOrderLineApi(params: any) {
  return request.get<any>({
    url: '/mfg/order_lines',
    params
  })
}

// 创建生产订单明细
export function createMfgOrderLineApi(params: any) {
  return request.post<any>({
    url: '/mfg/order_lines',
    params
  })
}

// 更新生产订单明细
export function updateMfgOrderLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/order_lines/${id}`,
    params
  })
}

// 删除生产订单明细
export function deleteMfgOrderLineApi(id: number) {
  return request.del<any>({
    url: `/mfg/order_lines/${id}`
  })
}
