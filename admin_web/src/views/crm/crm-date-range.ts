/** 接单日期：本地日历，与列表 Ransack receive_date_* 一致 */

export function formatYmd(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

export function receiveRangeToday(): { gte: string; lte: string } {
  const s = formatYmd(new Date())
  return { gte: s, lte: s }
}

/** 周一至周日（周一为一周开始） */
export function receiveRangeThisWeek(): { gte: string; lte: string } {
  const now = new Date()
  const dow = now.getDay()
  const mondayOffset = dow === 0 ? -6 : 1 - dow
  const monday = new Date(now)
  monday.setDate(now.getDate() + mondayOffset)
  const sunday = new Date(monday)
  sunday.setDate(monday.getDate() + 6)
  return { gte: formatYmd(monday), lte: formatYmd(sunday) }
}

export function receiveRangeThisMonth(): { gte: string; lte: string } {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 0)
  return { gte: formatYmd(start), lte: formatYmd(end) }
}

export function receiveRangeByQuick(kind: 'today' | 'week' | 'month'): {
  gte: string
  lte: string
} {
  if (kind === 'today') return receiveRangeToday()
  if (kind === 'week') return receiveRangeThisWeek()
  return receiveRangeThisMonth()
}

/** 新建页：将接单日期设为 今天 / 本周一 / 本月1日 */
export function receiveDatePickerForQuick(kind: 'today' | 'week' | 'month'): string {
  if (kind === 'today') return receiveRangeToday().gte
  if (kind === 'week') return receiveRangeThisWeek().gte
  return receiveRangeThisMonth().gte
}
