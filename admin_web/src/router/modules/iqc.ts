import { AppRouteRecord } from '@/types/router'

export const iqcRoutes: AppRouteRecord = {
  path: '/iqc',
  name: 'Iqc',
  component: '/iqc/index',
  meta: {
    title: 'menus.iqc.title',
    icon: 'ri:microscope-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'raw-inspections',
      name: 'IqcRawInspections',
      component: '/iqc/raw-inspections',
      meta: {
        title: 'menus.iqc.rawInspections',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    }
  ]
}
