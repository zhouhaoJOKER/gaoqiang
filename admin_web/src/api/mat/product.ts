import request from '@/utils/http'

// 获取产品列表
export function listMatProductApi(params: any) {
  return request.get<any>({
    url: '/mat/products',
    params
  })
}

// 创建产品
export function createMatProductApi(params: any) {
  return request.post<any>({
    url: '/mat/products',
    params
  })
}

// 访问产品详情
export function viewMatProductApi(params: any) {
  return request.get<any>({
    url: `/mat/products/${params.id}`,
    params
  })
}

// 产品更新
export function updateMatProductApi(id: string, params: any) {
  return request.put<any>({
    url: `/mat/products/${id}`,
    params
  })
}

// 产品删除
export function deleteMatProductApi(id: number) {
  return request.del<any>({
    url: `/mat/products/${id}`
  })
}

// 批量操作产品
export function batchActionMatProductApi(params: any) {
  return request.post<any>({
    url: '/mat/products/batch_action',
    params
  })
}

// 获取产品组合列表
export function listMatProductComboApi(params: any) {
  return request.get<any>({
    url: '/mat/combos',
    params
  })
}

// 创建产品组合
export function createMatProductComboApi(params: any) {
  return request.post<any>({
    url: '/mat/combos',
    params
  })
}

// 获取产品组合详情
export function viewMatProductComboApi(params: any) {
  return request.get<any>({
    url: `/mat/combos/${params.id}`,
    params
  })
}

// 更新产品组合
export function updateMatProductComboApi(id: string, params: any) {
  return request.put<any>({
    url: `/mat/combos/${id}`,
    params
  })
}

// 删除产品组合
export function deleteMatProductComboApi(id: number) {
  return request.del<any>({
    url: `/mat/combos/${id}`
  })
}
