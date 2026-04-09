import request from '@/utils/http'

// 获取工单列表
export function listMfgWorkOrderApi(params: any) {
  return request.get<any>({
    url: '/mfg/work_orders',
    params
  })
}

// 创建工单
export function createMfgWorkOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/work_orders',
    params
  })
}

// 访问工单详情
export function viewMfgWorkOrderApi(params: any) {
  return request.get<any>({
    url: `/mfg/work_orders/${params.id}`,
    params
  })
}

// 工单更新
export function updateMfgWorkOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/work_orders/${id}`,
    params
  })
}

// 工单删除
export function deleteMfgWorkOrderApi(id: number) {
  return request.del<any>({
    url: `/mfg/work_orders/${id}`
  })
}

// 批量操作工单
export function batchActionMfgWorkOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/work_orders/batch_action',
    params
  })
}

// 获取工单损耗列表
export function listMfgWorkOrderLossApi(params: any) {
  return request.get<any>({
    url: '/mfg/work_order_losses',
    params
  })
}

// 创建工单损耗
export function createMfgWorkOrderLossApi(params: any) {
  return request.post<any>({
    url: '/mfg/work_order_losses',
    params
  })
}

// 访问工单损耗详情
export function viewMfgWorkOrderLossApi(params: any) {
  return request.get<any>({
    url: `/mfg/work_order_losses/${params.id}`,
    params
  })
}

// 更新工单损耗
export function updateMfgWorkOrderLossApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/work_order_losses/${id}`,
    params
  })
}

// 删除工单损耗
export function deleteMfgWorkOrderLossApi(id: number) {
  return request.del<any>({
    url: `/mfg/work_order_losses/${id}`
  })
}

// 获取工单副产品列表
export function listMfgWorkOrderByproductApi(params: any) {
  return request.get<any>({
    url: '/mfg/work_order_byproducts',
    params
  })
}

// 创建工单副产品
export function createMfgWorkOrderByproductApi(params: any) {
  return request.post<any>({
    url: '/mfg/work_order_byproducts',
    params
  })
}

// 访问工单副产品详情
export function viewMfgWorkOrderByproductApi(params: any) {
  return request.get<any>({
    url: `/mfg/work_order_byproducts/${params.id}`,
    params
  })
}

// 更新工单副产品
export function updateMfgWorkOrderByproductApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/work_order_byproducts/${id}`,
    params
  })
}

// 删除工单副产品
export function deleteMfgWorkOrderByproductApi(id: number) {
  return request.del<any>({
    url: `/mfg/work_order_byproducts/${id}`
  })
}
