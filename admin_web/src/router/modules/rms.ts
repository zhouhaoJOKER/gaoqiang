import { AppRouteRecord } from '@/types/router'

export const rmsRoutes: AppRouteRecord = {
  path: '/rms',
  name: 'Rms',
  component: '/rms/index',
  meta: {
    title: 'menus.rms.title',
    icon: 'ri:file-list-3-line',
    roles: ['R_SUPER', 'R_ADMIN']
  },
  children: [
    {
      path: 'recipe-handovers',
      name: 'RmsRecipeHandovers',
      component: '/rms/recipe-handovers',
      meta: {
        title: 'menus.rms.recipeHandovers',
        keepAlive: true,
        roles: ['R_SUPER', 'R_ADMIN']
      }
    }
  ]
}
