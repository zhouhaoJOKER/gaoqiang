import request from '@/utils/http'

// 获取项目列表
export function listPmProjectApi(params: any) {
  return request.get<any>({
    url: '/pm/projects',
    params
  })
}

// 创建项目
export function createPmProjectApi(params: any) {
  return request.post<any>({
    url: '/pm/projects',
    params
  })
}

// 访问项目详情
export function viewPmProjectApi(params: any) {
  return request.get<any>({
    url: `/pm/projects/${params.id}`,
    params
  })
}

// 项目更新
export function updatePmProjectApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/projects/${id}`,
    params
  })
}

// 项目删除
export function deletePmProjectApi(id: number) {
  return request.del<any>({
    url: `/pm/projects/${id}`
  })
}

// 获取任务列列表
export function listPmStageApi(params: any) {
  return request.get<any>({
    url: '/pm/stages',
    params
  })
}

// 创建任务列
export function createPmStageApi(params: any) {
  return request.post<any>({
    url: '/pm/stages',
    params
  })
}

// 创建任务列
export function updatePmStageApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/stages/${id}`,
    params
  })
}

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
export function viewPmTaskApi(params: any) {
  return request.get<any>({
    url: `/pm/tasks/${params.id}`,
    params
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

// 创建工时
export function listPmTmApi(params: any) {
  return request.get<any>({
    url: '/pm/timesheets',
    params
  })
}

// 创建工时
export function createPmTmApi(params: any) {
  return request.post<any>({
    url: '/pm/timesheets',
    params
  })
}

// 更新工时
export function updatePmTmApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/timesheets/${id}`,
    params
  })
}

// 删除工时
export function deletePmTmApi(id: number) {
  return request.del<any>({
    url: `/pm/timesheets/${id}`
  })
}
