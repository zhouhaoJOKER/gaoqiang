import request from '@/utils/http'

// 获取领料出库单列表
export function listWmsPickOrderApi(params: any) {
  return request.get<any>({
    url: '/wms/pick_orders',
    params
  })
}

// 创建领料出库单
export function createWmsPickOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/pick_orders',
    params
  })
}

// 访问领料出库单详情
export function viewWmsPickOrderApi(params: any) {
  return request.get<any>({
    url: `/wms/pick_orders/${params.id}`,
    params
  })
}

// 领料出库单更新
export function updateWmsPickOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/pick_orders/${id}`,
    params
  })
}

// 领料出库单删除
export function deleteWmsPickOrderApi(id: number) {
  return request.del<any>({
    url: `/wms/pick_orders/${id}`
  })
}

// 批量操作领料出库单
export function batchActionWmsPickOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/pick_orders/batch_action',
    params
  })
}

// 获取领料出库单明细列表
export function listWmsPickOrderLineApi(params: any) {
  return request.get<any>({
    url: '/wms/pick_order_lines',
    params
  })
}

// 创建领料出库单明细
export function createWmsPickOrderLineApi(params: any) {
  return request.post<any>({
    url: '/wms/pick_order_lines',
    params
  })
}

// 更新领料出库单明细
export function updateWmsPickOrderLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/pick_order_lines/${id}`,
    params
  })
}

// 删除领料出库单明细
export function deleteWmsPickOrderLineApi(id: number) {
  return request.del<any>({
    url: `/wms/pick_order_lines/${id}`
  })
}
