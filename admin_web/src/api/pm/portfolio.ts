import request from '@/utils/http'

// 获取项目集信息
export function searchPmPortfolioApi(params: any) {
  return request.get<any>({
    url: '/pm/portfolios/search',
    params
  })
}

// 获取项目集列表
export function listPmPortfolioApi(params: any) {
  return request.get<any>({
    url: '/pm/portfolios',
    params
  })
}

// 创建项目集
export function createPmPortfolioApi(params: any) {
  return request.post<any>({
    url: '/pm/portfolios',
    params
  })
}

// 访问项目集详情
export function viewPmPortfolioApi(params: any) {
  return request.get<any>({
    url: `/pm/portfolios/${params.id}`,
    params
  })
}

// 项目集更新
export function updatePmPortfolioApi(id: string, params: any) {
  return request.put<any>({
    url: `/pm/portfolios/${id}`,
    params
  })
}

// 项目集删除
export function deletePmPortfolioApi(id: number) {
  return request.del<any>({
    url: `/pm/portfolios/${id}`
  })
}
