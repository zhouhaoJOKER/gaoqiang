import request from '@/utils/http'

// 获取用户信息
export function searchUserApi(params: any) {
  return request.get<any>({
    url: '/users/search',
    params
  })
}

// 获取用户列表
export function listUserApi(params: any) {
  return request.get<any>({
    url: '/users',
    params
  })
}

// 创建用户
export function createUserApi(params: any) {
  return request.post<any>({
    url: '/users',
    params
  })
}

// 访问用户详情
export function viewUserApi(params: any) {
  return request.get<any>({
    url: `/users/${params.id}`,
    params
  })
}

// 用户更新
export function updateUserApi(id: string, params: any) {
  return request.put<any>({
    url: `/users/${id}`,
    params
  })
}

// 用户删除
export function deleteUserApi(id: string) {
  return request.del<any>({
    url: `/users/${id}`
  })
}

// 用户导入
export function importUserApi(params: any) {
  return request.post<any>({
    url: '/users/import',
    params
  })
}

// 用户导出
export function exportUserApi(params: any) {
  return request.post<any>({
    url: '/users/export',
    params
  })
}

// 用户重置密码
export function resetUserPwdApi(params: any) {
  return request.post<any>({
    url: '/users/reset_password',
    params
  })
}

// 用户修改密码
export function updateUserPwdApi(params: any) {
  return request.post<any>({
    url: '/users/change_password',
    params
  })
}

// 发送重置密码邮件
export function sendResetPasswordEmailApi(id: string) {
  return request.post<any>({
    url: `/users/send_reset_password_email?id=${id}`
  })
}

// 批量操作用户
export function batchActionUserApi(params: any) {
  return request.post<any>({
    url: '/users/batch_action',
    params
  })
}

// 批量导入用户
export function batchImportUserApi(params: any) {
  // 如果包含文件，使用 FormData 处理
  if (params.file && params.file.uid) {
    const formData = new FormData()
    formData.append('import_type', params.import_type)
    formData.append('tag', params.tag)
    formData.append('file', params.file.raw || params.file)
    return request.post<any>({
      url: '/users/import',
      data: formData
    })
  }
  return request.post<any>({
    url: '/users/import',
    params
  })
}
