import request from '@/utils/http'

// 获取属性列表
export function listMatAttributeApi(params: any) {
  return request.get<any>({
    url: '/mat/attributes',
    params
  })
}

// 创建属性
export function createMatAttributeApi(params: any) {
  return request.post<any>({
    url: '/mat/attributes',
    params
  })
}

// 访问属性详情
export function viewMatAttributeApi(params: any) {
  return request.get<any>({
    url: `/mat/attributes/${params.id}`,
    params
  })
}

// 更新属性
export function updateMatAttributeApi(id: string | number, params: any) {
  return request.put<any>({
    url: `/mat/attributes/${id}`,
    params
  })
}

// 删除属性
export function deleteMatAttributeApi(id: number) {
  return request.del<any>({
    url: `/mat/attributes/${id}`
  })
}

// 获取属性值列表
export function listMatValueApi(params: any) {
  return request.get<any>({
    url: '/mat/values',
    params
  })
}

// 创建属性值
export function createMatValueApi(params: any) {
  return request.post<any>({
    url: '/mat/values',
    params
  })
}

// 更新属性值
export function updateMatValueApi(id: string | number, params: any) {
  return request.put<any>({
    url: `/mat/values/${id}`,
    params
  })
}

// 删除属性值
export function deleteMatValueApi(id: number) {
  return request.del<any>({
    url: `/mat/values/${id}`
  })
}

// 获取产品属性行列表
export function listMatAttributeLineApi(params: any) {
  return request.get<any>({
    url: '/mat/attribute_lines',
    params
  })
}

// 创建产品属性行
export function createMatAttributeLineApi(params: any) {
  return request.post<any>({
    url: '/mat/attribute_lines',
    params
  })
}

// 更新产品属性行
export function updateMatAttributeLineApi(id: string | number, params: any) {
  return request.put<any>({
    url: `/mat/attribute_lines/${id}`,
    params
  })
}

// 删除产品属性行
export function deleteMatAttributeLineApi(id: number) {
  return request.del<any>({
    url: `/mat/attribute_lines/${id}`
  })
}
