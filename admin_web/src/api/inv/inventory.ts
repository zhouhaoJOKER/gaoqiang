import request from '@/utils/http'

// 获取库存列表
export function listInvInventoryApi(params: any) {
  return request.get<any>({
    url: '/inv/inventories',
    params
  })
}

// 创建库存
export function createInvInventoryApi(params: any) {
  return request.post<any>({
    url: '/inv/inventories',
    params
  })
}

// 访问库存详情
export function viewInvInventoryApi(params: any) {
  return request.get<any>({
    url: `/inv/inventories/${params.id}`,
    params
  })
}

// 库存更新
export function updateInvInventoryApi(id: string, params: any) {
  return request.put<any>({
    url: `/inv/inventories/${id}`,
    params
  })
}

// 库存删除
export function deleteInvInventoryApi(id: number) {
  return request.del<any>({
    url: `/inv/inventories/${id}`
  })
}

// 批量操作库存
export function batchActionInvInventoryApi(params: any) {
  return request.post<any>({
    url: '/inv/inventories/batch_action',
    params
  })
}
