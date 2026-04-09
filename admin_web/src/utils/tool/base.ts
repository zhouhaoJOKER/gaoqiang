/**
 * @description ProTable组件请求前处理为后端需要的格式
 * @param params ProTable组件请求参数
 * @returns 处理后的参数
 * */
export function handleProTableParams(params: any) {
  delete params.created_at
  delete params.updated_at
  const newParams: Record<string, any> = {}
  for (const key in params) {
    if (['page', 'per_page'].includes(key)) {
      newParams[key] = params[key]
    } else {
      newParams[`q[${key}]`] = params[key]
    }
  }

  return newParams
}
