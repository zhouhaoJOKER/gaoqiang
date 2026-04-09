import request from '@/utils/http'

export function listIqcRawApi(params: any) {
  return request.get<any>({ url: '/iqc/raws', params })
}

export function createIqcRawApi(params: any) {
  return request.post<any>({ url: '/iqc/raws', params })
}

export function viewIqcRawApi(params: any) {
  return request.get<any>({ url: `/iqc/raws/${params.id}`, params })
}

export function updateIqcRawApi(id: string | number, params: any) {
  return request.put<any>({ url: `/iqc/raws/${id}`, params })
}

export function deleteIqcRawApi(id: number) {
  return request.del<any>({ url: `/iqc/raws/${id}` })
}

export function batchActionIqcRawApi(params: any) {
  return request.post<any>({ url: '/iqc/raws/batch_action', params })
}

export function listIqcRawLineApi(params: any) {
  return request.get<any>({ url: '/iqc/raw_lines', params })
}
