import request from '@/utils/http'

// 获取调拨单列表
export function listWmsTransferOrderApi(params: any) {
  return request.get<any>({
    url: '/wms/transfer_orders',
    params
  })
}

// 创建调拨单
export function createWmsTransferOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/transfer_orders',
    params
  })
}

// 访问调拨单详情
export function viewWmsTransferOrderApi(params: any) {
  return request.get<any>({
    url: `/wms/transfer_orders/${params.id}`,
    params
  })
}

// 调拨单更新
export function updateWmsTransferOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/transfer_orders/${id}`,
    params
  })
}

// 调拨单删除
export function deleteWmsTransferOrderApi(id: number) {
  return request.del<any>({
    url: `/wms/transfer_orders/${id}`
  })
}

// 批量操作调拨单
export function batchActionWmsTransferOrderApi(params: any) {
  return request.post<any>({
    url: '/wms/transfer_orders/batch_action',
    params
  })
}

// 获取调拨单明细列表
export function listWmsTransferOrderLineApi(params: any) {
  return request.get<any>({
    url: '/wms/transfer_order_lines',
    params
  })
}

// 创建调拨单明细
export function createWmsTransferOrderLineApi(params: any) {
  return request.post<any>({
    url: '/wms/transfer_order_lines',
    params
  })
}

// 更新调拨单明细
export function updateWmsTransferOrderLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/transfer_order_lines/${id}`,
    params
  })
}

// 删除调拨单明细
export function deleteWmsTransferOrderLineApi(id: number) {
  return request.del<any>({
    url: `/wms/transfer_order_lines/${id}`
  })
}
