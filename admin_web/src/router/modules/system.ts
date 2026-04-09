import { AppRouteRecord } from '@/types/router'

export const systemRoutes: AppRouteRecord = {
  path: '/system',
  name: 'System',
  component: '/system/index',
  meta: {
    title: 'menus.system.title',
    icon: 'ri:user-3-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'user',
      name: 'User',
      component: '/system/user',
      meta: {
        title: 'menus.system.user',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'user-center',
      name: 'UserCenter',
      component: '/system/user-center',
      meta: {
        title: 'menus.system.userCenter',
        isHide: true,
        keepAlive: true,
        isHideTab: true
      }
    },
    {
      path: 'user-view',
      name: 'UserView',
      component: '/system/user/user-view',
      meta: {
        title: 'menus.system.userView',
        isHide: true,
        keepAlive: true,
        isHideTab: false,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'role',
      name: 'Role',
      component: '/system/role',
      meta: {
        title: 'menus.system.role',
        keepAlive: true,
        roles: ['R_SUPER']
      }
    },
    {
      path: 'department',
      name: 'Department',
      component: '/system/department',
      meta: {
        title: 'menus.system.department',
        keepAlive: true,
        roles: ['R_SUPER'],
        authList: [
          { authMark: 'add', title: '新增部门' },
          { authMark: 'view', title: '查看部门' },
          { authMark: 'batchAdd', title: '批量新增部门' },
          { authMark: 'batchEdit', title: '批量修改部门' },
          { authMark: 'batchDelete', title: '批量删除部门' },
          { authMark: 'batchDisable', title: '批量禁用部门' },
          { authMark: 'batchEnable', title: '批量启用部门' },
          { authMark: 'import', title: '导入部门' },
          { authMark: 'export', title: '导出部门' },
          { authMark: 'edit', title: '编辑部门' },
          { authMark: 'clone', title: '克隆部门' },
          { authMark: 'delete', title: '删除部门' }
        ]
      }
    },
    {
      path: 'department/view/:id',
      name: 'DepartmentView',
      component: '/system/department/department-view',
      meta: {
        title: 'menus.system.departmentView',
        isHide: true,
        keepAlive: true,
        isHideTab: false,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    },
    {
      path: 'setting',
      name: 'Setting',
      component: '/system/setting',
      meta: {
        title: 'menus.system.setting',
        keepAlive: true,
        isHideTab: false,
        roles: ['R_SUPER']
      }
    },
    {
      path: 'log',
      name: 'Log',
      component: '/system/log',
      meta: {
        title: 'menus.system.log',
        keepAlive: true,
        roles: ['R_SUPER']
      }
    },
    {
      path: 'menu',
      name: 'Menus',
      component: '/system/menu',
      meta: {
        title: 'menus.system.menu',
        keepAlive: true
      }
    },
    {
      path: 'nested',
      name: 'Nested',
      component: '',
      meta: {
        title: 'menus.system.nested',
        icon: 'ri:menu-unfold-3-line',
        keepAlive: true
      },
      children: [
        {
          path: 'menu1',
          name: 'NestedMenu1',
          component: '/system/nested/menu1',
          meta: {
            title: 'menus.system.menu1',
            icon: 'ri:align-justify',
            keepAlive: true
          }
        },
        {
          path: 'menu2',
          name: 'NestedMenu2',
          component: '',
          meta: {
            title: 'menus.system.menu2',
            icon: 'ri:align-justify',
            keepAlive: true
          },
          children: [
            {
              path: 'menu2-1',
              name: 'NestedMenu2-1',
              component: '/system/nested/menu2',
              meta: {
                title: 'menus.system.menu21',
                icon: 'ri:align-justify',
                keepAlive: true
              }
            }
          ]
        },
        {
          path: 'menu3',
          name: 'NestedMenu3',
          component: '',
          meta: {
            title: 'menus.system.menu3',
            icon: 'ri:align-justify',
            keepAlive: true
          },
          children: [
            {
              path: 'menu3-1',
              name: 'NestedMenu3-1',
              component: '/system/nested/menu3',
              meta: {
                title: 'menus.system.menu31',
                keepAlive: true
              }
            },
            {
              path: 'menu3-2',
              name: 'NestedMenu3-2',
              component: '',
              meta: {
                title: 'menus.system.menu32',
                keepAlive: true
              },
              children: [
                {
                  path: 'menu3-2-1',
                  name: 'NestedMenu3-2-1',
                  component: '/system/nested/menu3/menu3-2',
                  meta: {
                    title: 'menus.system.menu321',
                    keepAlive: true
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
