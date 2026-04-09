import request from '@/utils/http'

// 获取项目列表
export function listPmTaskApi(params: any) {
  return request.get<any>({
    url: '/pm/tasks',
    params
  })
}

// 创建项目
export function createPmTaskApi(params: any) {
  return request.post<any>({
    url: '/pm/tasks',
    params
  })
}

// 访问项目详情
export function viewPmTaskApi(params: any, options?: { showErrorMessage?: boolean }) {
  return request.get<any>({
    url: `/pm/tasks/${params.id}`,
    params,
    showErrorMessage: options?.showErrorMessage
  })
}

// 项目更新
export function updatePmTaskApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/tasks/${id}`,
    params
  })
}

// 项目删除
export function deletePmTaskApi(id: number) {
  return request.del<any>({
    url: `/pm/tasks/${id}`
  })
}
