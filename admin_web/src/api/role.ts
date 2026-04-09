import request from '@/utils/http'

// 获取角色信息
export function searchRoleApi(params: any) {
  return request.get<any>({
    url: '/roles/search',
    params
  })
}

// 获取角色列表
export function listRoleApi(params: any) {
  return request.get<any>({
    url: '/roles',
    params
  })
}

// 创建角色
export function createRoleApi(params: any) {
  return request.post<any>({
    url: '/roles',
    params
  })
}

// 访问角色详情
export function viewRoleApi(params: any) {
  return request.get<any>({
    url: `/roles/${params.id}`,
    params
  })
}

// 角色更新
export function updateRoleApi(id: string, params: any) {
  return request.put<any>({
    url: `/roles/${id}`,
    params
  })
}

// 角色删除
export function deleteRoleApi(id: string) {
  return request.del<any>({
    url: `/roles/${id}`
  })
}

// 批量操作角色
export function batchActionRoleApi(params: any) {
  return request.post<any>({
    url: '/roles/batch_action',
    params
  })
}

// 批量导入角色
export function batchImportRoleApi(params: any) {
  // 如果包含文件，使用 FormData 处理
  if (params.file && params.file.uid) {
    const formData = new FormData()
    formData.append('import_type', params.import_type)
    formData.append('tag', params.tag)
    formData.append('file', params.file.raw || params.file)
    return request.post<any>({
      url: '/roles/import',
      data: formData
    })
  }
  return request.post<any>({
    url: '/roles/import',
    params
  })
}
