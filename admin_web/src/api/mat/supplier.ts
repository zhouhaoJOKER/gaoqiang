import request from '@/utils/http'

// 获取供应商列表
export function listMatSupplierApi(params: any) {
  return request.get<any>({
    url: '/pur/suppliers',
    params
  })
}

// 创建供应商
export function createMatSupplierApi(params: any) {
  return request.post<any>({
    url: '/pur/suppliers',
    params
  })
}

// 访问供应商详情
export function viewMatSupplierApi(params: any) {
  return request.get<any>({
    url: `/pur/suppliers/${params.id}`,
    params
  })
}

// 供应商更新
export function updateMatSupplierApi(id: string, params: any) {
  return request.put<any>({
    url: `/pur/suppliers/${id}`,
    params
  })
}

// 供应商删除
export function deleteMatSupplierApi(id: number) {
  return request.del<any>({
    url: `/pur/suppliers/${id}`
  })
}

// 批量操作供应商
export function batchActionMatSupplierApi(params: any) {
  return request.post<any>({
    url: '/pur/suppliers/batch_action',
    params
  })
}
