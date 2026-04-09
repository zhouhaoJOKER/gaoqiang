import request from '@/utils/http'

// 获取拆解单列表
export function listMfgDisassemblyOrderApi(params: any) {
  return request.get<any>({
    url: '/mfg/disassembly_orders',
    params
  })
}

// 创建拆解单
export function createMfgDisassemblyOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/disassembly_orders',
    params
  })
}

// 访问拆解单详情
export function viewMfgDisassemblyOrderApi(params: any) {
  return request.get<any>({
    url: `/mfg/disassembly_orders/${params.id}`,
    params
  })
}

// 拆解单更新
export function updateMfgDisassemblyOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/disassembly_orders/${id}`,
    params
  })
}

// 拆解单删除
export function deleteMfgDisassemblyOrderApi(id: number) {
  return request.del<any>({
    url: `/mfg/disassembly_orders/${id}`
  })
}

// 批量操作拆解单
export function batchActionMfgDisassemblyOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/disassembly_orders/batch_action',
    params
  })
}
