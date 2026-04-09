import request from '@/utils/http'

// 获取物品列表
export function listMatItemApi(params: any) {
  return request.get<any>({
    url: '/mat/items',
    params
  })
}

// 创建物品
export function createMatItemApi(params: any) {
  return request.post<any>({
    url: '/mat/items',
    params
  })
}

// 访问物品详情
export function viewMatItemApi(params: any) {
  return request.get<any>({
    url: `/mat/items/${params.id}`,
    params
  })
}

// 物品更新
export function updateMatItemApi(id: string, params: any) {
  return request.put<any>({
    url: `/mat/items/${id}`,
    params
  })
}
