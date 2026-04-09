/**
 * CRM 订单状态展示：Property.color 可能是十六进制或 Element 语义（如 warning）。
 */

const SEMANTIC = new Set(['success', 'warning', 'info', 'danger', 'primary'])

export type CrmStatusTagType = 'success' | 'warning' | 'info' | 'danger' | 'primary'

export function crmOrderStatusTagAttrs(color?: string | null): {
  type?: CrmStatusTagType
  color?: string
  effect: 'light' | 'dark' | 'plain'
} {
  const c = (color ?? '').trim()
  if (!c) {
    return { type: 'info', effect: 'light' }
  }
  if (c.startsWith('#') && /^#[0-9a-fA-F]{6}$/.test(c)) {
    return { color: c, effect: 'light' }
  }
  const lower = c.toLowerCase()
  if (SEMANTIC.has(lower)) {
    return { type: lower as CrmStatusTagType, effect: 'light' }
  }
  return { type: 'primary', effect: 'light' }
}

/** 列表行背景：语义色用 Element 浅色变量，十六进制用半透明，其它回退默认绿底 */
export function crmOrderRowBgByStatus(color?: string | null): string {
  const c = (color ?? '').trim()
  if (!c) return '#e8f5e9'
  if (c.startsWith('#') && /^#[0-9a-fA-F]{6}$/.test(c)) {
    return `${c}44`
  }
  const map: Record<string, string> = {
    success: 'var(--el-color-success-light-9)',
    warning: 'var(--el-color-warning-light-9)',
    info: 'var(--el-color-info-light-9)',
    danger: 'var(--el-color-danger-light-9)',
    primary: 'var(--el-color-primary-light-9)'
  }
  return map[c.toLowerCase()] ?? '#e8f5e9'
}
