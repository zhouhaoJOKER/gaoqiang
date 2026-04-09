export const PREORDER_CART_KEY = 'mat_preorder_cart_v1'

export interface PreorderCartLine {
  product_id: number | string
  product_name: string
  model: string
  color: string
  weight: string
  quantity: number
  unit: string
}

export function loadPreorderCart(): Record<string, PreorderCartLine> {
  try {
    const raw = sessionStorage.getItem(PREORDER_CART_KEY)
    if (!raw) return {}
    const parsed = JSON.parse(raw) as Record<string, PreorderCartLine>
    return parsed && typeof parsed === 'object' ? parsed : {}
  } catch {
    return {}
  }
}

export function savePreorderCart(map: Record<string, PreorderCartLine>): void {
  sessionStorage.setItem(PREORDER_CART_KEY, JSON.stringify(map))
}

export function cartTotalQty(map: Record<string, PreorderCartLine>): number {
  return Object.values(map).reduce((s, l) => s + (Number(l.quantity) || 0), 0)
}

export function snapshotFromProduct(p: Record<string, any>): PreorderCartLine {
  const cf =
    p.custom_fields && typeof p.custom_fields === 'object'
      ? (p.custom_fields as Record<string, string>)
      : {}
  return {
    product_id: p.id,
    product_name: p.name || '',
    model: p.code || '—',
    color: cf.color || p.material || '—',
    weight: cf.weight_g || cf.gram_weight || p.nominal_capacity || '—',
    quantity: 1,
    unit: p.uom_name || '—'
  }
}
