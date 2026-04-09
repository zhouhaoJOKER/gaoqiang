import request from '@/utils/http'

// 获取文档树状结构列表
export function listPmDocumentTreeApi(params: any) {
  return request.get<any>({
    url: '/pm/documents_trees',
    params
  })
}

// 获取文档列表
export function listPmDocumentApi(params: any) {
  return request.get<any>({
    url: '/pm/documents',
    params
  })
}

// 创建文档
export function createPmDocumentApi(params: any) {
  return request.post<any>({
    url: '/pm/documents',
    params
  })
}

// 访问文档详情
export function viewPmDocumentApi(params: any) {
  return request.get<any>({
    url: `/pm/documents/${params.id}`,
    params
  })
}

// 更新文档
export function updatePmDocumentApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/documents/${id}`,
    params
  })
}

// 删除文档
export function deletePmDocumentApi(id: number) {
  return request.del<any>({
    url: `/pm/documents/${id}`
  })
}
