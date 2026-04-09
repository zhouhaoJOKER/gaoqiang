import request from '@/utils/http'

// 获取菜单信息
export function searchCompanyApi(params: any) {
  return request.get<any>({
    url: '/companies/search',
    params
  })
}

// 获取菜单列表
export function listCompanyApi(params: any) {
  return request.get<any>({
    url: '/companies',
    params
  })
}

// 创建菜单
export function createCompanyApi(params: any) {
  return request.post<any>({
    url: '/companies',
    params
  })
}

// 访问菜单详情
export function viewCompanyApi(params: any) {
  return request.get<any>({
    url: `/companies/${params.id}`,
    params
  })
}

// 菜单更新
export function updateCompanyApi(id: string, params: any) {
  return request.put<any>({
    url: `/companies/${id}`,
    params
  })
}

// 菜单删除
export function deleteCompanyApi(id: number) {
  return request.del<any>({
    url: `/companies/${id}`
  })
}
