import request from '@/utils/http'

// 获取库存锁定列表
export function listInvInventoryLockApi(params: any) {
  return request.get<any>({
    url: '/inv/inventory_locks',
    params
  })
}

// 创建库存锁定
export function createInvInventoryLockApi(params: any) {
  return request.post<any>({
    url: '/inv/inventory_locks',
    params
  })
}

// 访问库存锁定详情
export function viewInvInventoryLockApi(params: any) {
  return request.get<any>({
    url: `/inv/inventory_locks/${params.id}`,
    params
  })
}

// 库存锁定更新
export function updateInvInventoryLockApi(id: string, params: any) {
  return request.put<any>({
    url: `/inv/inventory_locks/${id}`,
    params
  })
}

// 库存锁定删除
export function deleteInvInventoryLockApi(id: number) {
  return request.del<any>({
    url: `/inv/inventory_locks/${id}`
  })
}

// 批量操作库存锁定
export function batchActionInvInventoryLockApi(params: any) {
  return request.post<any>({
    url: '/inv/inventory_locks/batch_action',
    params
  })
}
