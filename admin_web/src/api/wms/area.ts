import request from '@/utils/http'

// 获取库区列表
export function listWmsAreaApi(params: any) {
  return request.get<any>({
    url: '/wms/areas',
    params
  })
}

// 创建库区
export function createWmsAreaApi(params: any) {
  return request.post<any>({
    url: '/wms/areas',
    params
  })
}

// 访问库区详情
export function viewWmsAreaApi(params: any) {
  return request.get<any>({
    url: `/wms/areas/${params.id}`,
    params
  })
}

// 库区更新
export function updateWmsAreaApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/areas/${id}`,
    params
  })
}

// 库区删除
export function deleteWmsAreaApi(id: number) {
  return request.del<any>({
    url: `/wms/areas/${id}`
  })
}

// 批量操作库区
export function batchActionWmsAreaApi(params: any) {
  return request.post<any>({
    url: '/wms/areas/batch_action',
    params
  })
}
