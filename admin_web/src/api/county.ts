import request from '@/utils/http'

export function listCountyApi(params: any) {
  return request.get<any>({ url: '/counties', params })
}

export function createCountyApi(params: any) {
  return request.post<any>({ url: '/counties', params })
}

export function viewCountyApi(params: any) {
  return request.get<any>({ url: `/counties/${params.id}`, params })
}

export function updateCountyApi(id: string, params: any) {
  return request.put<any>({ url: `/counties/${id}`, params })
}

export function deleteCountyApi(id: number) {
  return request.del<any>({ url: `/counties/${id}` })
}
