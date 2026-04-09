import request from '@/utils/http'

// 获取项目模板列表
export function listPmProjectTemplateApi(params: any) {
  return request.get<any>({
    url: '/pm/templates',
    params
  })
}

// 创建项目模板
export function createPmProjectTemplateApi(params: any) {
  return request.post<any>({
    url: '/pm/templates',
    params
  })
}

// 访问项目模板详情
export function viewPmProjectTemplateApi(params: any) {
  return request.get<any>({
    url: `/pm/templates/${params.id}`,
    params
  })
}

// 项目模板更新
export function updatePmProjectTemplateApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/templates/${id}`,
    params
  })
}

// 项目模板删除
export function deletePmProjectTemplateApi(id: number) {
  return request.del<any>({
    url: `/pm/templates/${id}`
  })
}
