import request from '@/utils/http'

// 获取货位列表
export function listWmsLocationApi(params: any) {
  return request.get<any>({
    url: '/wms/locations',
    params
  })
}

// 创建货位
export function createWmsLocationApi(params: any) {
  return request.post<any>({
    url: '/wms/locations',
    params
  })
}

// 访问货位详情
export function viewWmsLocationApi(params: any) {
  return request.get<any>({
    url: `/wms/locations/${params.id}`,
    params
  })
}

// 货位更新
export function updateWmsLocationApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/locations/${id}`,
    params
  })
}

// 货位删除
export function deleteWmsLocationApi(id: number) {
  return request.del<any>({
    url: `/wms/locations/${id}`
  })
}

// 批量操作货位
export function batchActionWmsLocationApi(params: any) {
  return request.post<any>({
    url: '/wms/locations/batch_action',
    params
  })
}
