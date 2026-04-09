import request from '@/utils/http'

// 获取菜单信息
export function searchPropertyApi(params: any) {
  return request.get<any>({
    url: '/properties/search',
    params
  })
}

// 获取菜单列表
export function listPropertyApi(params: any, options?: { showErrorMessage?: boolean }) {
  return request.get<any>({
    url: '/properties',
    params,
    showErrorMessage: options?.showErrorMessage
  })
}

// 创建菜单
export function createPropertyApi(params: any) {
  return request.post<any>({
    url: '/properties',
    params
  })
}

// 访问菜单详情
export function viewPropertyApi(params: any) {
  return request.get<any>({
    url: `/properties/${params.id}`,
    params
  })
}

// 菜单更新
export function updatePropertyApi(id: string, params: any) {
  return request.put<any>({
    url: `/properties/${id}`,
    params
  })
}

// 菜单删除
export function deletePropertyApi(id: number) {
  return request.del<any>({
    url: `/properties/${id}`
  })
}
