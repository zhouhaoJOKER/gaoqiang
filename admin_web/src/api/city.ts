import request from '@/utils/http'

export function listCityApi(params: any) {
  return request.get<any>({ url: '/cities', params })
}

export function createCityApi(params: any) {
  return request.post<any>({ url: '/cities', params })
}

export function viewCityApi(params: any) {
  return request.get<any>({ url: `/cities/${params.id}`, params })
}

export function updateCityApi(id: string, params: any) {
  return request.put<any>({ url: `/cities/${id}`, params })
}

export function deleteCityApi(id: number) {
  return request.del<any>({ url: `/cities/${id}` })
}
