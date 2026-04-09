import { encrypt } from './toBase64'

export const toJwt = (params: unknown): string => {
  const header = encrypt(
    JSON.stringify({
      alg: 'HS256',
      typ: 'JWT',
      num: Math.floor(Math.random() * (1e4 - 1e3))
    })
  )
  const payload = encrypt(JSON.stringify(params))
  const signature = encrypt(new Date().valueOf().toString())
  const result = `${header}.${payload}.${signature}`
  return result
}
