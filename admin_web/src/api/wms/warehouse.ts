import request from '@/utils/http'

// 获取仓库列表
export function listWmsWarehouseApi(params: any) {
  return request.get<any>({
    url: '/wms/warehouses',
    params
  })
}

// 创建仓库
export function createWmsWarehouseApi(params: any) {
  return request.post<any>({
    url: '/wms/warehouses',
    params
  })
}

// 访问仓库详情
export function viewWmsWarehouseApi(params: any) {
  return request.get<any>({
    url: `/wms/warehouses/${params.id}`,
    params
  })
}

// 仓库更新
export function updateWmsWarehouseApi(id: string, params: any) {
  return request.put<any>({
    url: `/wms/warehouses/${id}`,
    params
  })
}

// 仓库删除
export function deleteWmsWarehouseApi(id: number) {
  return request.del<any>({
    url: `/wms/warehouses/${id}`
  })
}

// 批量操作仓库
export function batchActionWmsWarehouseApi(params: any) {
  return request.post<any>({
    url: '/wms/warehouses/batch_action',
    params
  })
}
