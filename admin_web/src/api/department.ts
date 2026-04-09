import request from '@/utils/http'

// 获取部门信息
export function searchDepartmentApi(params: any) {
  return request.get<any>({
    url: '/departments/search',
    params
  })
}

// 获取部门树状结构列表
export function listDepartmentTreeApi(params: any) {
  return request.get<any>({
    url: '/departments_trees',
    params
  })
}

// 获取部门列表
export function listDepartmentApi(params: any) {
  return request.get<any>({
    url: '/departments',
    params
  })
}

// 创建部门
export function createDepartmentApi(params: any) {
  return request.post<any>({
    url: '/departments',
    params
  })
}

// 访问部门详情
export function viewDepartmentApi(params: any) {
  return request.get<any>({
    url: `/departments/${params.id}`,
    params
  })
}

// 更新部门
export function updateDepartmentApi(id: string, params: any) {
  return request.put<any>({
    url: `/departments/${id}`,
    params
  })
}

// 删除部门
export function deleteDepartmentApi(id: number) {
  return request.del<any>({
    url: `/departments/${id}`
  })
}

// 批量操作部门
export function batchActionDepartmentApi(params: any) {
  return request.post<any>({
    url: '/departments/batch_action',
    params
  })
}

// 批量导入部门
export function batchImportDepartmentApi(params: any) {
  // 如果包含文件，使用 FormData 处理
  if (params.file && params.file.uid) {
    const formData = new FormData()
    formData.append('import_type', params.import_type)
    formData.append('tag', params.tag)
    formData.append('file', params.file.raw || params.file)
    return request.post<any>({
      url: '/departments/import',
      data: formData
    })
  }
  return request.post<any>({
    url: '/departments/import',
    params
  })
}
