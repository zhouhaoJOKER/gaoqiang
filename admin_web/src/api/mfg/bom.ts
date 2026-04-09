import request from '@/utils/http'

// 获取BOM列表
export function listMfgBomApi(params: any) {
  return request.get<any>({
    url: '/mfg/boms',
    params
  })
}

// 创建BOM
export function createMfgBomApi(params: any) {
  return request.post<any>({
    url: '/mfg/boms',
    params
  })
}

// 访问BOM详情
export function viewMfgBomApi(params: any) {
  return request.get<any>({
    url: `/mfg/boms/${params.id}`,
    params
  })
}

// BOM更新
export function updateMfgBomApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/boms/${id}`,
    params
  })
}

// BOM删除
export function deleteMfgBomApi(id: number) {
  return request.del<any>({
    url: `/mfg/boms/${id}`
  })
}

// 批量操作BOM
export function batchActionMfgBomApi(params: any) {
  return request.post<any>({
    url: '/mfg/boms/batch_action',
    params
  })
}

// 获取BOM明细行列表
export function listMfgBomLineApi(params: any) {
  return request.get<any>({
    url: '/mfg/bom_lines',
    params
  })
}

// 创建BOM明细行
export function createMfgBomLineApi(params: any) {
  return request.post<any>({
    url: '/mfg/bom_lines',
    params
  })
}

// 更新BOM明细行
export function updateMfgBomLineApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/bom_lines/${id}`,
    params
  })
}

// 删除BOM明细行
export function deleteMfgBomLineApi(id: number) {
  return request.del<any>({
    url: `/mfg/bom_lines/${id}`
  })
}

// 获取BOM副产品列表
export function listMfgBomByproductApi(params: any) {
  return request.get<any>({
    url: '/mfg/bom_byproducts',
    params
  })
}

// 创建BOM副产品
export function createMfgBomByproductApi(params: any) {
  return request.post<any>({
    url: '/mfg/bom_byproducts',
    params
  })
}

// 访问BOM副产品详情
export function viewMfgBomByproductApi(params: any) {
  return request.get<any>({
    url: `/mfg/bom_byproducts/${params.id}`,
    params
  })
}

// 更新BOM副产品
export function updateMfgBomByproductApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/bom_byproducts/${id}`,
    params
  })
}

// 删除BOM副产品
export function deleteMfgBomByproductApi(id: number) {
  return request.del<any>({
    url: `/mfg/bom_byproducts/${id}`
  })
}

// 获取BOM损耗列表
export function listMfgBomLossApi(params: any) {
  return request.get<any>({
    url: '/mfg/bom_losses',
    params
  })
}

// 创建BOM损耗
export function createMfgBomLossApi(params: any) {
  return request.post<any>({
    url: '/mfg/bom_losses',
    params
  })
}

// 访问BOM损耗详情
export function viewMfgBomLossApi(params: any) {
  return request.get<any>({
    url: `/mfg/bom_losses/${params.id}`,
    params
  })
}

// 更新BOM损耗
export function updateMfgBomLossApi(id: string, params: any) {
  return request.put<any>({
    url: `/mfg/bom_losses/${id}`,
    params
  })
}

// 删除BOM损耗
export function deleteMfgBomLossApi(id: number) {
  return request.del<any>({
    url: `/mfg/bom_losses/${id}`
  })
}
