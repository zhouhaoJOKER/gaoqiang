import request from '@/utils/http'

// 获取配置列表
export function listSettingApi(params: any) {
  return request.get<any>({
    url: '/settings',
    params
  })
}

// 创建配置
export function createSettingApi(params: any) {
  return request.post<any>({
    url: '/settings',
    params
  })
}

// 访问配置详情
export function viewSettingApi(params: any) {
  return request.get<any>({
    url: `/settings/${params.id}`,
    params
  })
}

// 配置更新
export function updateSettingApi(id: string, params: any) {
  return request.put<any>({
    url: `/settings/${id}`,
    params
  })
}

// 配置删除
export function deleteSettingApi(id: string) {
  return request.del<any>({
    url: `/settings/${id}`
  })
}
