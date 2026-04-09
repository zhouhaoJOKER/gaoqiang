/**
 * 在线预购专用请求：走 /api/v2，使用 VITE_PREORDER_API_TOKEN，不触发登录态 401 登出
 */
import axios, { AxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'

const baseURL = import.meta.env.VITE_PREORDER_API_BASE || '/api/v2'
const token = import.meta.env.VITE_PREORDER_API_TOKEN || ''

const preorderAxios = axios.create({
  baseURL,
  timeout: 120000,
  validateStatus: (status) => status >= 200 && status < 300,
  headers: {
    'Content-Type': 'application/json'
  },
  transformResponse: [
    (data, headers) => {
      const ct = headers['content-type']
      if (ct?.includes('application/json') && typeof data === 'string') {
        try {
          return JSON.parse(data)
        } catch {
          return data
        }
      }
      return data
    }
  ]
})

preorderAxios.interceptors.request.use((config) => {
  if (token) {
    config.headers.set('Authorization', `Bearer ${token}`)
  }
  return config
})

preorderAxios.interceptors.response.use(
  (response) => {
    const body = response.data as { code?: number; msg?: string }
    if (body?.code === 200) {
      return response
    }
    const msg = (body as any)?.msg || '请求失败'
    ElMessage.error(msg)
    return Promise.reject(new Error(msg))
  },
  (error) => {
    const msg = error?.response?.data?.msg || error?.message || '网络错误'
    ElMessage.error(msg)
    return Promise.reject(error)
  }
)

export interface PreorderApiEnvelope<T = unknown> {
  code: number
  success?: number
  msg?: string
  data?: T
  total?: number
  page?: number
  size?: number
}

export async function preorderGet<T = unknown>(
  url: string,
  config?: AxiosRequestConfig
): Promise<PreorderApiEnvelope<T>> {
  const res = await preorderAxios.get<PreorderApiEnvelope<T>>(url, config)
  return res.data as PreorderApiEnvelope<T>
}

export async function preorderPost<T = unknown>(
  url: string,
  data?: Record<string, unknown>
): Promise<PreorderApiEnvelope<T>> {
  const res = await preorderAxios.post<PreorderApiEnvelope<T>>(url, data)
  return res.data as PreorderApiEnvelope<T>
}
