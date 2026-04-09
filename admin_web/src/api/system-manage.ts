import request from '@/utils/http'
// import { AppRouteRecord } from '@/types/router'

// 站点信息
export interface SiteInfo {
  name: string
  titleName: string
  openCaptcha: boolean
  authorName: string
  authorUrl: string
  logo: string
  favicon: string
  icp: string
  policeCode: string
  versionCode: string
  copyright: string
  slogan: string
  host: string
}

// 获取网站配置信息
export async function fetchSiteInfo() {
  // console.log('fetchSiteInfo: Starting API call to /site_info')
  const response = await request.get<any>({ url: '/site_info' })
  // console.log('fetchSiteInfo: API response received:', response)
  return response
}

// 获取用户列表
export function fetchGetUserList(params: Api.SystemManage.UserSearchParams) {
  return request.get<Api.SystemManage.UserList>({
    url: '/api/user/list',
    params
  })
}

// 获取角色列表
export function fetchGetRoleList(params: Api.SystemManage.RoleSearchParams) {
  return request.get<Api.SystemManage.RoleList>({
    url: '/api/role/list',
    params
  })
}

// 获取菜单列表
export function fetchGetMenuList() {
  return request.get<any>({
    url: '/menu'
  })
}

// 基础文件上传
export function uploadApi(params: any) {
  return request.post<any>({
    url: '/basic_upload',
    params
  })
}

// 测试接口
export function testApi(params: any) {
  return request.post<any>({
    url: '/test',
    params
  })
}

// 测试文件上传
export function uploadTestApi(params: any) {
  return request.post<any>({
    url: '/upload_test',
    params
  })
}

// 日志接口
export function listLogApi(params: any) {
  return request.get<any>({
    url: '/logs',
    params
  })
}
