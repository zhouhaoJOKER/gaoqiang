import request from '@/utils/http'

// 获取生产入库单列表
export function listWmsReceiveOrderApi(params: any) {
  return request.get<any>({
    url: '/wms/receive_orders',
    params
  })
}

// 创建生产入库单
export function createWmsReceiveOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/receive_orders',
    params
  })
}

// 访问生产入库单详情
export function viewWmsReceiveOrderApi(params: any) {
  return request.get<any>({
    url: `/wms/receive_orders/${params.id}`,
    params
  })
}

// 生产入库单更新
export function updateWmsReceiveOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/receive_orders/${id}`,
    params
  })
}

// 生产入库单删除
export function deleteWmsReceiveOrderApi(id: number) {
  return request.del<any>({
    url: `/wms/receive_orders/${id}`
  })
}

// 批量操作生产入库单
export function batchActionWmsReceiveOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/receive_orders/batch_action',
    params
  })
}

// 获取生产入库单明细列表
export function listWmsReceiveOrderLineApi(params: any) {
  return request.get<any>({
    url: '/wms/receive_order_lines',
    params
  })
}

// 创建生产入库单明细
export function createWmsReceiveOrderLineApi(params: any) {
  return request.post<any>({
    url: '/wms/receive_order_lines',
    params
  })
}

// 更新生产入库单明细
export function updateWmsReceiveOrderLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/receive_order_lines/${id}`,
    params
  })
}

// 删除生产入库单明细
export function deleteWmsReceiveOrderLineApi(id: number) {
  return request.del<any>({
    url: `/wms/receive_order_lines/${id}`
  })
}
