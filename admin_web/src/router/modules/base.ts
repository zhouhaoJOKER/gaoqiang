import { AppRouteRecord } from '@/types/router'

export const baseRoutes: AppRouteRecord = {
  path: '/base',
  name: 'Base',
  component: '/base/index',
  meta: {
    title: 'menus.base.title',
    icon: 'ri:database-2-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'regions',
      name: 'BaseRegions',
      component: '/base/regions',
      meta: {
        title: 'menus.base.regions',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'properties',
      name: 'BaseProperties',
      component: '/base/properties',
      meta: {
        title: 'menus.base.properties',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'doc-number-rules',
      name: 'BaseDocNumberRules',
      component: '/base/doc-number-rules',
      meta: {
        title: 'menus.base.docNumberRules',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'workflow-templates',
      name: 'BaseWorkflowTemplates',
      component: '/base/workflow-templates',
      meta: {
        title: 'menus.base.workflowTemplates',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'workflow-templates/:id',
      name: 'BaseWorkflowTemplateDetail',
      component: '/base/workflow-templates/detail',
      meta: {
        title: 'menus.base.workflowTemplateDetail',
        roles: ['R_SUPER', 'R_ADMIN']
      }
    }
  ]
}
