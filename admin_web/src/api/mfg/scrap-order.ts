import request from '@/utils/http'

// 获取报废单列表
export function listMfgScrapOrderApi(params: any) {
  return request.get<any>({
    url: '/mfg/scrap_orders',
    params
  })
}

// 创建报废单
export function createMfgScrapOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/scrap_orders',
    params
  })
}

// 访问报废单详情
export function viewMfgScrapOrderApi(params: any) {
  return request.get<any>({
    url: `/mfg/scrap_orders/${params.id}`,
    params
  })
}

// 报废单更新
export function updateMfgScrapOrderApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/scrap_orders/${id}`,
    params
  })
}

// 报废单删除
export function deleteMfgScrapOrderApi(id: number) {
  return request.del<any>({
    url: `/mfg/scrap_orders/${id}`
  })
}

// 批量操作报废单
export function batchActionMfgScrapOrderApi(params: any) {
  return request.post<any>({
    url: '/mfg/scrap_orders/batch_action',
    params
  })
}
