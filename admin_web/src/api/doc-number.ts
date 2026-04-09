import request from '@/utils/http'

export function listDocNumberRuleApi(params: any) {
  return request.get<any>({ url: '/doc_number_rules', params })
}

export function createDocNumberRuleApi(params: any) {
  return request.post<any>({ url: '/doc_number_rules', params })
}

export function viewDocNumberRuleApi(params: { id: string | number }) {
  return request.get<any>({ url: `/doc_number_rules/${params.id}`, params })
}

export function updateDocNumberRuleApi(id: string, params: any) {
  return request.put<any>({ url: `/doc_number_rules/${id}`, params })
}

export function deleteDocNumberRuleApi(id: number) {
  return request.del<any>({ url: `/doc_number_rules/${id}` })
}

/** 预览下一个单号（不消耗序列） */
export function previewDocNumberApi(key: string) {
  return request.get<any>({ url: '/doc_number_rules/preview', params: { key } })
}

/** 生成下一个单号（消耗序列） */
export function generateDocNumberApi(key: string) {
  return request.post<any>({ url: '/doc_number_rules/generate', params: { key } })
}
