import request from '@/utils/http'

// 获取文件列表
export function listPmFileApi(params: any) {
  return request.get<any>({
    url: '/pm/files',
    params
  })
}

// 创建文件/目录
export function createPmFileApi(params: any) {
  return request.post<any>({
    url: '/pm/files',
    params
  })
}

// 访问文件详情
export function viewPmFileApi(params: any) {
  return request.get<any>({
    url: `/pm/files/${params.id}`,
    params
  })
}

// 更新文件
export function updatePmFileApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/files/${id}`,
    params
  })
}

// 删除文件
export function deletePmFileApi(id: number) {
  return request.del<any>({
    url: `/pm/files/${id}`
  })
}

// 移动文件
export function movePmFileApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/files/${id}/move`,
    params
  })
}
