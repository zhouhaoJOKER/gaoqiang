import request from '@/utils/http'

// 获取菜单信息
export function searchMenuApi(params: any) {
  return request.get<any>({
    url: '/menus/search',
    params
  })
}

// 获取菜单列表
export function listMenuApi(params: any) {
  return request.get<any>({
    url: '/menus',
    params
  })
}

// 创建菜单
export function createMenuApi(params: any) {
  return request.post<any>({
    url: '/menus',
    params
  })
}

// 访问菜单详情
export function viewMenuApi(params: any) {
  return request.get<any>({
    url: `/menus/${params.id}`,
    params
  })
}

// 菜单更新
export function updateMenuApi(id: string, params: any) {
  return request.put<any>({
    url: `/menus/${id}`,
    params
  })
}

// 菜单删除
export function deleteMenuApi(id: number) {
  return request.del<any>({
    url: `/menus/${id}`
  })
}
