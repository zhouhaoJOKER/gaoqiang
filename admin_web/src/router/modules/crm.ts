import { AppRouteRecord } from '@/types/router'

export const crmRoutes: AppRouteRecord = {
  path: '/crm',
  name: 'Crm',
  component: '/crm/index',
  meta: {
    title: 'menus.crm.title',
    icon: 'ri:user-heart-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'pre-orders',
      name: 'CrmPreOrders',
      component: '/crm/pre-orders',
      meta: {
        title: 'CRM预购单',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'orders',
      name: 'CrmOrders',
      component: '/crm/orders',
      meta: {
        title: 'CRM订单',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'order-lines',
      name: 'CrmOrderLines',
      component: '/crm/order-lines',
      meta: {
        title: '订单行',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'order-lines/:id',
      name: 'CrmOrderLinesDetail',
      component: '/crm/order-lines/detail',
      meta: {
        title: '订单行详情',
        keepAlive: false,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'orders/new',
      name: 'CrmOrderCreate',
      component: '/crm/orders/create',
      meta: {
        title: '新建CRM订单',
        keepAlive: false,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'orders/:id',
      name: 'CrmOrderDetail',
      component: '/crm/orders/detail',
      meta: {
        title: 'CRM订单详情',
        keepAlive: false,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    }
  ]
}
