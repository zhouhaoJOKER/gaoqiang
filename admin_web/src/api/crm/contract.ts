import request from '@/utils/http'

export function listCrmContractApi(params: any) {
  return request.get<any>({ url: '/fm/contracts', params })
}

export function createCrmContractApi(params: any) {
  return request.post<any>({ url: '/fm/contracts', params })
}

export function viewCrmContractApi(params: any) {
  return request.get<any>({ url: `/fm/contracts/${params.id}`, params })
}

export function updateCrmContractApi(id: string, params: any) {
  return request.put<any>({ url: `/fm/contracts/${id}`, params })
}

export function deleteCrmContractApi(id: number) {
  return request.del<any>({ url: `/fm/contracts/${id}` })
}

export function batchActionCrmContractApi(params: any) {
  return request.post<any>({ url: '/fm/contracts/batch_action', params })
}

export function listCrmCollectionApi(params: any) {
  return request.get<any>({ url: '/fm/collections', params })
}
