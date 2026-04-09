/**
 * useSystemInfo - 快速入口管理
 *
 * 管理顶部栏的快速入口功能，提供应用列表和快速链接的配置和过滤。
 * 支持动态启用/禁用、自定义排序、响应式宽度控制等功能。
 *
 * ## 主要功能
 *
 * 1. 应用列表管理 - 获取启用的应用列表，自动按排序权重排序
 * 2. 快速链接管理 - 获取启用的快速链接，支持自定义排序
 * 3. 响应式配置 - 所有配置自动响应变化，无需手动更新
 * 4. 宽度控制 - 提供最小显示宽度配置，支持响应式布局
 *
 * @module useSystemInfo
 * @author iStar Pro Team
 */

import { ref, onMounted, watch } from 'vue'
import { fetchSiteInfo, type SiteInfo } from '@/api/system-manage'
import { useSettingStore } from '@/store/modules/setting'
import { storeToRefs } from 'pinia'

// console.log('useSyteminfo.ts module loaded')

const SITE_INFO_KEY = 'siteInfoCache'

function getCachedSiteInfo() {
  // console.log('getCachedSiteInfo: Reading from localStorage...')
  try {
    const cached = localStorage.getItem(SITE_INFO_KEY)
    // console.log('getCachedSiteInfo: Raw data:', cached)
    if (cached) {
      const parsed = JSON.parse(cached)
      // console.log('getCachedSiteInfo: Parsed data:', parsed)

      // Check if cache is expired (7 days = 604800000 ms)
      const isExpired = Date.now() - parsed.timestamp > 604800000
      // console.log('getCachedSiteInfo: Cache expired:', isExpired)

      // Remove timestamp from the returned data to match SiteInfo type
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { timestamp, ...siteInfo } = parsed

      return {
        siteInfo,
        isExpired,
        hasCache: true
      }
    }
  } catch (err) {
    console.error('Failed to read cached site info:', err)
  }
  // console.log('getCachedSiteInfo: No data found')
  return {
    siteInfo: null,
    isExpired: true,
    hasCache: false
  }
}

function cacheSiteInfo(info: SiteInfo) {
  // console.log('cacheSiteInfo: Saving to localStorage...:', info)
  try {
    // Add timestamp to cache data for expiration check
    const cacheData = {
      ...info,
      timestamp: Date.now()
    }
    localStorage.setItem(SITE_INFO_KEY, JSON.stringify(cacheData))
    // console.log('cacheSiteInfo: Save successful')
  } catch (err) {
    console.error('Failed to cache site info:', err)
  }
}

/**
 * 比较两个对象是否相等
 */
function deepEqual<T extends object>(a: T | null | undefined, b: T | null | undefined): boolean {
  if (a === b) return true
  if (a == null || b == null) return false
  if (typeof a !== 'object' || typeof b !== 'object') return false
  const keysA = Object.keys(a)
  const keysB = Object.keys(b)
  if (keysA.length !== keysB.length) return false
  for (const key of keysA) {
    const valA = (a as any)[key]
    const valB = (b as any)[key]
    if (typeof valA === 'object' && typeof valB === 'object') {
      if (!deepEqual(valA, valB)) return false
    } else if (valA !== valB) {
      return false
    }
  }
  return true
}

export function useSystemInfo() {
  // console.log('useSystemInfo hook is being executed!')
  const settingStore = useSettingStore()
  const { systemInfo } = storeToRefs(settingStore)
  const loading = ref(false)
  const error = ref<unknown>(null)

  // 设置页面favicon
  const setFavicon = (faviconUrl: string | undefined) => {
    if (!faviconUrl) return

    // 查找现有的favicon元素
    let faviconEl = document.querySelector('link[rel="shortcut icon"]') as HTMLLinkElement | null

    // 如果不存在favicon元素，则创建一个新的
    if (!faviconEl) {
      faviconEl = document.createElement('link')
      faviconEl.rel = 'shortcut icon'
      faviconEl.type = 'image/x-icon'
      document.head.appendChild(faviconEl)
    }

    // 设置favicon的URL
    faviconEl.href = faviconUrl
  }

  onMounted(async () => {
    // console.log('useSystemInfo onMounted hook start')
    try {
      const { siteInfo: cachedInfo, isExpired, hasCache } = getCachedSiteInfo()

      // If cache exists and is not expired, use it and exit early
      if (hasCache && !isExpired) {
        settingStore.updateSystemInfo(cachedInfo!)
        if (cachedInfo!.titleName) {
          document.title = cachedInfo!.titleName
        }
        if (cachedInfo!.favicon) {
          setFavicon(cachedInfo!.favicon)
        }
        return
      }

      // Cache is expired or doesn't exist, fetch API
      loading.value = true
      const data = await fetchSiteInfo()
      const systemInfoData = data.data
      // console.log('useSystemInfo: Site info fetched:', systemInfoData)
      // console.log('useSystemInfo: Cache status:', cachedInfo)
      // console.log('useSystemInfo: Data type:', typeof systemInfoData)

      // Compare new data with cached data
      const isDifferent = !deepEqual(cachedInfo, systemInfoData)
      // console.log('比较新数据和缓存数据是否一致:', isDifferent)

      if (isDifferent) {
        // Update store if data is different from cache
        settingStore.updateSystemInfo(systemInfoData)
        if (data.titleName) {
          document.title = data.titleName
        }
        if (systemInfoData.favicon) {
          setFavicon(systemInfoData.favicon)
        }
      }

      // Cache the new data regardless (to refresh timestamp)
      cacheSiteInfo(systemInfoData)
    } catch (err) {
      error.value = err
      console.error('Failed to fetch site info:', err)
    } finally {
      loading.value = false
    }
  })

  // 监听favicon变化并更新
  watch(
    () => systemInfo.value.favicon,
    (newFavicon) => {
      setFavicon(newFavicon)
    },
    { immediate: true }
  )

  return { systemInfo, loading, error }
}
