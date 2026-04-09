import { preorderGet, preorderPost } from '@/utils/http/preorder'

/** 预购 V2：产品分类（Property） */
export function preorderListPropertiesApi(params: Record<string, unknown>) {
  return preorderGet<unknown[]>('/mat/properties', { params })
}

/** 预购 V2：产品列表 */
export function preorderListProductsApi(params: Record<string, unknown>) {
  return preorderGet<unknown[]>('/mat/products', { params })
}

/** 预购 V2：提交预购单 */
export function preorderCreatePreOrderApi(payload: Record<string, unknown>) {
  return preorderPost<{ id: number }>('/mat/pre_orders', payload)
}
