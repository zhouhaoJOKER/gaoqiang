import request from '@/utils/http'

export function listProvinceApi(params: any) {
  return request.get<any>({ url: '/provinces', params })
}

export function createProvinceApi(params: any) {
  return request.post<any>({ url: '/provinces', params })
}

export function viewProvinceApi(params: any) {
  return request.get<any>({ url: `/provinces/${params.id}`, params })
}

export function updateProvinceApi(id: string, params: any) {
  return request.put<any>({ url: `/provinces/${id}`, params })
}

export function deleteProvinceApi(id: number) {
  return request.del<any>({ url: `/provinces/${id}` })
}
