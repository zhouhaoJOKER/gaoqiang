import request from '@/utils/http'

export function listPurContractApi(params: any) {
  return request.get<any>({ url: '/pur/contracts', params })
}

export function viewPurContractApi(params: { id: string | number }) {
  return request.get<any>({ url: `/pur/contracts/${params.id}`, params })
}

export function createPurContractApi(params: any) {
  return request.post<any>({ url: '/pur/contracts', params })
}

export function listPurCollectionApi(params: any) {
  return request.get<any>({ url: '/pur/collections', params })
}
