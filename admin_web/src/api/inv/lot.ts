import request from '@/utils/http'

// 获取批次序列号列表
export function listInvLotApi(params: any) {
  return request.get<any>({
    url: '/inv/lots',
    params
  })
}

// 访问批次序列号详情
export function viewInvLotApi(params: any) {
  return request.get<any>({
    url: `/inv/lots/${params.id}`,
    params
  })
}

// 批次序列号更新
export function updateInvLotApi(id: string, params: any) {
  return request.put<any>({
    url: `/inv/lots/${id}`,
    params
  })
}
