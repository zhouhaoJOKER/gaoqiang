import request from '@/utils/http'

// 获取活动信息
export function searchActivityApi(params: any) {
  return request.get<any>({
    url: '/activities/search',
    params
  })
}

// 获取活动列表
export function listActivityApi(params: any, options?: { showErrorMessage?: boolean }) {
  return request.get<any>({
    url: '/activities',
    params,
    showErrorMessage: options?.showErrorMessage
  })
}

// 创建活动
export function createActivityApi(params: any) {
  return request.post<any>({
    url: '/activities',
    params
  })
}

// 访问活动详情
export function viewActivityApi(params: any) {
  return request.get<any>({
    url: `/activities/${params.id}`,
    params
  })
}

// 活动更新
export function updateActivityApi(id: string, params: any) {
  return request.put<any>({
    url: `/activities/${id}`,
    params
  })
}

// 活动删除
export function deleteActivityApi(id: number) {
  return request.del<any>({
    url: `/activities/${id}`
  })
}
