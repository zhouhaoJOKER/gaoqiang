import request from '@/utils/http'
import { useUserStore } from '@/store/modules/user'

/**
 * 登录
 * @param params 登录参数
 * @returns 登录响应
 */
export function fetchLogin(params: Api.Auth.LoginParams) {
  // 创建userStore实例
  const userStore = useUserStore()

  return request
    .post<Api.Auth.LoginResponse>({
      url: '/login',
      params
    })
    .then((response) => {
      // 登录成功后，存储token
      if (response?.token) {
        userStore.setToken(response.token, response.refreshToken)
        userStore.setLoginStatus(true)
      }
      return response
    })
}

/**
 * 注册
 * @param params 注册参数
 * @returns 注册响应
 */
export function fetchRegister(params: any) {
  return request
    .post<any>({
      url: '/register',
      params
    })
    .then((response) => {
      // 注册成功后，存储token
      // if (response?.token) {
      //   userStore.setToken(response.token, response.refreshToken)
      //   userStore.setLoginStatus(true)
      // }
      return response
    })
}

/**
 * 忘记密码
 * @param params 忘记密码参数
 * @returns 忘记密码响应
 */
export function fetchForgotPassword(params: any) {
  return request
    .post<any>({
      url: '/forgot_password',
      params
    })
    .then((response) => {
      // 忘记密码成功后，存储token
      // if (response?.token) {
      //   userStore.setToken(response.token, response.refreshToken)
      //   userStore.setLoginStatus(true)
      // }
      return response
    })
}

/**
 * 获取用户信息
 * @returns 用户信息
 */
export function fetchGetUserInfo() {
  return request
    .get<any>({
      url: '/info'
    })
    .then((res) => {
      // 获取用户信息成功后，存储用户信息
      console.log(res)
      // const userInfo = res.data
      // const userStore = useUserStore()
      // userStore.setUserInfo(userInfo)
      return res.data
    })
}

/**
 * 重置密码
 * @param params 重置密码参数
 * @returns 重置密码响应
 */
export function resetPasswordAPI(params: any) {
  return request
    .post<any>({
      url: '/reset_password',
      params
    })
    .then((response) => {
      return response
    })
}

// 确认邮箱
export function confirmUserApi(params: any) {
  return request.post<any>({
    url: '/confirm',
    params
  })
}
