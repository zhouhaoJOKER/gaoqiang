import { AppRouteRecord } from '@/types/router'
import { dashboardRoutes } from './dashboard'
import { systemRoutes } from './system'
import { baseRoutes } from './base'
import { resultRoutes } from './result'
import { exceptionRoutes } from './exception'
import { rmsRoutes } from './rms'
import { iqcRoutes } from './iqc'
import { crmRoutes } from './crm'

/**
 * 导出所有模块化路由
 */
export const routeModules: AppRouteRecord[] = [
  dashboardRoutes,
  systemRoutes,
  baseRoutes,
  resultRoutes,
  exceptionRoutes,
  rmsRoutes,
  iqcRoutes,
  crmRoutes
]
