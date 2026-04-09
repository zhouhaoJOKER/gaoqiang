import request from '@/utils/http'

// 获取退货单列表
export function listWmsReturnOrderApi(params: any) {
  return request.get<any>({
    url: '/wms/return_orders',
    params
  })
}

// 创建退货单
export function createWmsReturnOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/return_orders',
    params
  })
}

// 访问退货单详情
export function viewWmsReturnOrderApi(params: any) {
  return request.get<any>({
    url: `/wms/return_orders/${params.id}`,
    params
  })
}

// 退货单更新
export function updateWmsReturnOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/return_orders/${id}`,
    params
  })
}

// 退货单删除
export function deleteWmsReturnOrderApi(id: number) {
  return request.del<any>({
    url: `/wms/return_orders/${id}`
  })
}

// 批量操作退货单
export function batchActionWmsReturnOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/return_orders/batch_action',
    params
  })
}

// 获取退货单明细列表
export function listWmsReturnOrderLineApi(params: any) {
  return request.get<any>({
    url: '/wms/return_order_lines',
    params
  })
}

// 创建退货单明细
export function createWmsReturnOrderLineApi(params: any) {
  return request.post<any>({
    url: '/wms/return_order_lines',
    params
  })
}

// 更新退货单明细
export function updateWmsReturnOrderLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/return_order_lines/${id}`,
    params
  })
}

// 删除退货单明细
export function deleteWmsReturnOrderLineApi(id: number) {
  return request.del<any>({
    url: `/wms/return_order_lines/${id}`
  })
}
