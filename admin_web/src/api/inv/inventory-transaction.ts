import request from '@/utils/http'

// 获取库存流水列表
export function listInvInventoryTransactionApi(params: any) {
  return request.get<any>({
    url: '/inv/inventory_transactions',
    params
  })
}

// 访问库存流水详情
export function viewInvInventoryTransactionApi(params: any) {
  return request.get<any>({
    url: `/inv/inventory_transactions/${params.id}`,
    params
  })
}

// 创建库存流水（通常由系统自动创建，但保留接口）
export function createInvInventoryTransactionApi(params: any) {
  return request.post<any>({
    url: '/inv/inventory_transactions',
    params
  })
}
