import request from '@/utils/http'

export function listRecipeHandoverApi(params: any) {
  return request.get<any>({ url: '/rms/handovers', params })
}

export function createRecipeHandoverApi(params: any) {
  return request.post<any>({ url: '/rms/handovers', params })
}

export function viewRecipeHandoverApi(params: any) {
  return request.get<any>({ url: `/rms/handovers/${params.id}`, params })
}

export function updateRecipeHandoverApi(id: string | number, params: any) {
  return request.put<any>({ url: `/rms/handovers/${id}`, params })
}

export function deleteRecipeHandoverApi(id: number) {
  return request.del<any>({ url: `/rms/handovers/${id}` })
}

export function batchActionRecipeHandoverApi(params: any) {
  return request.post<any>({ url: '/rms/handovers/batch_action', params })
}

export function listRecipeHandoverLineApi(params: any) {
  return request.get<any>({ url: '/rms/handover_lines', params })
}

export function listRecipeHandoverContractApi(params: any) {
  return request.get<any>({ url: '/rms/handover_contracts', params })
}
