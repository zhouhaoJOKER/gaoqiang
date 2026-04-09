import { AppRouteRecordRaw } from '@/utils/router'

/**
 * 静态路由配置（不需要权限就能访问的路由）
 *
 * 属性说明：
 * isHideTab: true 表示不在标签页中显示
 *
 * 注意事项：
 * 1、path、name 不要和动态路由冲突，否则会导致路由冲突无法访问
 * 2、静态路由不管是否登录都可以访问
 */
export const staticRoutes: AppRouteRecordRaw[] = [
  // 不需要登录就能访问的路由示例
  // {
  //   path: '/welcome',
  //   name: 'WelcomeStatic',
  //   component: () => import('@views/dashboard/console/index.vue'),
  //   meta: { title: 'menus.dashboard.title' }
  // },

  {
    path: '/icons',
    name: 'IconShowcase',
    component: () => import('@/components/IconShowcase.vue'),
    meta: { title: '图标展示', isHideTab: false }
  },
  {
    path: '/privacy-policy',
    name: 'PrivacyPolicy',
    component: () => import('@views/privacy-policy/index.vue'),
    meta: { title: 'Privacy Policy', isHideTab: true }
  },
  {
    path: '/auth/login',
    name: 'Login',
    component: () => import('@views/auth/login/index.vue'),
    meta: { title: 'menus.login.title', isHideTab: true }
  },
  {
    path: '/auth/register',
    name: 'Register',
    component: () => import('@views/auth/register/index.vue'),
    meta: { title: 'menus.register.title', isHideTab: true }
  },
  {
    path: '/auth/forget-password',
    name: 'ForgetPassword',
    component: () => import('@views/auth/forget-password/index.vue'),
    meta: { title: 'menus.forgetPassword.title', isHideTab: true }
  },
  {
    path: '/auth/reset-password',
    name: 'ResetPassword',
    component: () => import('@views/auth/reset-password/index.vue'),
    meta: { title: 'menus.resetPassword.title', isHideTab: true }
  },
  {
    path: '/auth/confirm-mail',
    name: 'ConfirmMail',
    component: () => import('@views/auth/confirm-mail/index.vue'),
    meta: { title: 'menus.confirmMail.title', isHideTab: true }
  },
  {
    path: '/pm/portfolios/:id',
    name: 'PortfolioDetail',
    component: () => import('@/views/pm/portfolios/detail.vue'),
    meta: { title: '项目集详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/pm/projects/:id',
    name: 'ProjectDetail',
    component: () => import('@/views/pm/projects/detail.vue'),
    meta: { title: '项目详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/mat/products/:id',
    name: 'MatProductDetail',
    component: () => import('@/views/mat/products/detail.vue'),
    meta: { title: '产品详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/clients/:id',
    name: 'CrmClientDetail',
    component: () => import('@/views/crm/clients/detail.vue'),
    meta: { title: '客户详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/contacts/:id',
    name: 'CrmContactDetail',
    component: () => import('@/views/crm/contacts/detail.vue'),
    meta: { title: '联系人详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/addresses/:id',
    name: 'CrmAddressDetail',
    component: () => import('@/views/crm/addresses/detail.vue'),
    meta: { title: '地址详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/spec-items/:id',
    name: 'CrmSpecItemDetail',
    component: () => import('@/views/crm/spec-items/detail.vue'),
    meta: { title: '指标项目详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/invoices/:id',
    name: 'CrmInvoiceDetail',
    component: () => import('@/views/crm/invoices/detail.vue'),
    meta: { title: '开票信息详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/crm/quotations/:id',
    name: 'CrmQuotationDetail',
    component: () => import('@/views/crm/quotations/detail.vue'),
    meta: { title: '报价单详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/fm/contracts/:id',
    name: 'CrmContractDetail',
    component: () => import('@/views/fm/contracts/detail.vue'),
    meta: { title: '合同详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/pur/contracts/:id',
    name: 'PurContractDetail',
    component: () => import('@/views/pur/contracts/detail.vue'),
    meta: { title: '采购合同详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/pur/suppliers/:id',
    name: 'PurSupplierDetail',
    component: () => import('@/views/pur/suppliers/detail.vue'),
    meta: { title: '供应商详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/pur/contacts/:id',
    name: 'PurContactDetail',
    component: () => import('@/views/pur/contacts/detail.vue'),
    meta: { title: '联系人详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/base/doc-number-rules',
    name: 'BaseDocNumberRules',
    component: () => import('@/views/base/doc-number-rules/index.vue'),
    meta: { title: 'menus.base.docNumberRules', isHideTab: false }
  },
  {
    path: '/base/workflow-templates/:id',
    name: 'BaseWorkflowTemplateDetail',
    component: () => import('@/views/base/workflow-templates/detail.vue'),
    meta: { title: 'menus.base.workflowTemplateDetail', isHideTab: false }
  },
  {
    path: '/crm/handovers/:id',
    name: 'CrmHandoverDetail',
    component: () => import('@/views/crm/handovers/detail.vue'),
    meta: { title: '交接单详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/rms/recipe-handovers/:id',
    name: 'RmsRecipeHandoverDetail',
    component: () => import('@/views/rms/recipe-handovers/detail.vue'),
    meta: { title: 'menus.rms.recipeHandoverDetail', isHideTab: false, isFullPage: false }
  },
  {
    path: '/iqc/raw-inspections/:id',
    name: 'IqcRawInspectionDetail',
    component: () => import('@/views/iqc/raw-inspections/detail.vue'),
    meta: { title: 'menus.iqc.rawInspectionDetail', isHideTab: false, isFullPage: false }
  },
  {
    path: '/inv/lots/:id',
    name: 'InvLotDetail',
    component: () => import('@/views/inv/lots/detail.vue'),
    meta: { title: '批次序列号详情', isHideTab: false, isFullPage: false }
  },
  {
    path: '/pm/tasks/:id',
    name: 'TaskDetail',
    component: () => import('@/views/pm/projects/modules/task-detail.vue'),
    meta: { title: '任务详情', isHideTab: false, isFullPage: true }
  },
  {
    path: '/preorder',
    name: 'Preorder',
    component: () => import('@/views/preorder/catalog.vue'),
    meta: { title: '在线预购', isHideTab: true }
  },
  {
    path: '/preorder/checkout',
    name: 'PreorderCheckout',
    component: () => import('@/views/preorder/checkout.vue'),
    meta: { title: '预购下单', isHideTab: true }
  },
  {
    path: '/403',
    name: 'Exception403',
    component: () => import('@views/exception/403/index.vue'),
    meta: { title: '403', isHideTab: true }
  },
  {
    path: '/405',
    name: 'Exception405',
    component: () => import('@views/exception/403/405.vue'),
    meta: { title: '405', isHideTab: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'Exception404',
    component: () => import('@views/exception/404/index.vue'),
    meta: { title: '404', isHideTab: true }
  },
  {
    path: '/500',
    name: 'Exception500',
    component: () => import('@views/exception/500/index.vue'),
    meta: { title: '500', isHideTab: true }
  },
  {
    path: '/outside',
    component: () => import('@views/index/index.vue'),
    name: 'Outside',
    meta: { title: 'menus.outside.title' },
    children: [
      // iframe 内嵌页面
      {
        path: '/outside/iframe/:path',
        name: 'Iframe',
        component: () => import('@/views/outside/Iframe.vue'),
        meta: { title: 'iframe' }
      }
    ]
  }
]
