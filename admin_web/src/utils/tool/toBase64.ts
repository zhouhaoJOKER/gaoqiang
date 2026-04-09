import dayjs from 'dayjs'
import { Base64 } from 'js-base64'

/********************************
 * @desc   格式化日期 yyyy-mm-dd hh:mm:ss
 * @params Date
 * @return String    eg. 2018-01-27 16:15:01
 ******************************** */
const formatDate = (time: Date | number | string): string => {
  const date = new Date(time)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()

  const hours = date.getHours()
  const minutes = date.getMinutes()
  const seconds = date.getSeconds()

  const formatNumber = (n: number | string): string => {
    const s = n.toString()
    return s[1] ? s : '0' + s
  }

  return (
    [year, month, day].map(formatNumber).join('-') +
    ' ' +
    [hours, minutes, seconds].map(formatNumber).join(':')
  )
}

const HHmmss = (time: Date | number | string): string => {
  return dayjs(time).format('HH:mm:ss')
}

/*****************************
 * @desc 字符串加密（用于登录时加密密码）
 *       加密方式
 *       原字符串末尾加5位随机数字
 *       使用Base64编码
 *       删除 \n ==
 * @params String
 * @return String
 * **************************** */
const encrypt = (text: string): string => {
  // text += Math.floor(Math.random() * (1e4 - 1e3) + 1e4);
  const encodeText = Base64.encode(text)
  const result = encodeText.replace(/[=]=||\n/g, '').replace('=', '')
  return result
}

/*****************************
 * @desc 字符串解密（用于解密密码）
 * @params String
 * @return String
 * **************************** */
const decrypt = (text: string): string => {
  const decodeText = Base64.decode(text)
  return decodeText
}

const hasRole = (name: string, roles: string[]): boolean => {
  return roles.includes(name)
}

export { decrypt, encrypt, formatDate, hasRole, HHmmss }
