<!-- 在线预购：全屏产品目录（无需登录） -->
<template>
  <div class="preorder-catalog">
    <header class="preorder-header">
      <div class="preorder-header-left">
        <h1 class="preorder-title">在线预购</h1>
        <span class="preorder-sub">无需登录，选择产品后可直接提交预购单</span>
      </div>
      <div class="preorder-header-actions">
        <ElBadge :value="cartQty" :hidden="cartQty === 0" class="preorder-badge">
          <ElButton @click="scrollToCartHint">购物车</ElButton>
        </ElBadge>
        <ElButton type="primary" :disabled="cartQty === 0" @click="goCheckout">去下单</ElButton>
        <ElButton link type="primary" @click="goLogin">返回登录</ElButton>
      </div>
    </header>

    <div v-loading="loading" class="preorder-main">
      <ElAlert
        v-if="!tokenConfigured"
        type="warning"
        :closable="false"
        show-icon
        class="mb-3"
        title="未配置 VITE_PREORDER_API_TOKEN，无法加载预购数据。请在环境变量中配置与后端 PREORDER_API_TOKEN 一致的令牌。"
      />

      <template v-if="!loading && roots.length === 0 && tokenConfigured">
        <ElEmpty description="暂无产品分类" />
      </template>

      <template v-else>
        <ElCard class="filter-card" shadow="never">
          <ElTabs v-model="activeRootId" class="root-tabs">
            <ElTabPane
              v-for="root in roots"
              :key="String(root.id)"
              :label="root.name"
              :name="String(root.id)"
            />
          </ElTabs>

          <div class="spec-filter-wrap">
            <button
              class="spec-pill"
              :class="{ active: activeSpecId === '' }"
              type="button"
              @click="activeSpecId = ''"
            >
              全部规格
            </button>
            <button
              v-for="spec in currentSpecs"
              :key="String(spec.id)"
              class="spec-pill"
              :class="{ active: activeSpecId === String(spec.id) }"
              type="button"
              @click="activeSpecId = String(spec.id)"
            >
              {{ spec.name }}
            </button>
          </div>
        </ElCard>

        <div class="product-grid">
          <template v-if="!loading && filteredProducts.length === 0">
            <div class="spec-empty text-sm text-gray-400">当前筛选下暂无产品</div>
          </template>
          <div v-for="item in filteredProducts" :key="item.id" class="product-cell">
            <div class="product-card">
              <ElCheckbox
                class="product-check"
                :model-value="isInCart(item.id)"
                @update:model-value="(v) => toggleCart(item, Boolean(v))"
              />
              <div class="product-media">
                <ElImage :src="imgUrl(item)" fit="contain" class="product-img">
                  <template #error>
                    <div class="img-ph"><span>无图</span></div>
                  </template>
                </ElImage>
              </div>

              <div class="product-meta">
                <div class="line-1">
                  <span class="code">{{ item.code || '—' }}</span>
                  <ElTag size="small" effect="plain" type="primary">{{
                    item.category_name || '未分类'
                  }}</ElTag>
                </div>
                <div class="name">{{ item.name || '未命名产品' }}</div>

                <dl class="details">
                  <div class="d-item"
                    ><dt>材质</dt><dd>{{ item.material || '—' }}</dd></div
                  >
                  <div class="d-item"
                    ><dt>公称容量</dt><dd>{{ item.nominal_capacity || '—' }}</dd></div
                  >
                  <div class="d-item"
                    ><dt>满口容量</dt><dd>{{ item.full_capacity || '—' }}</dd></div
                  >
                  <div class="d-item"
                    ><dt>口径</dt><dd>{{ item.caliber || '—' }}</dd></div
                  >
                  <div class="d-item"
                    ><dt>带盖高度</dt><dd>{{ item.cap_height || '—' }}</dd></div
                  >
                  <div class="d-item"
                    ><dt>最大直径</dt><dd>{{ item.max_diameter || '—' }}</dd></div
                  >
                  <div class="d-item d-item-full"
                    ><dt>贴标尺寸</dt><dd>{{ item.label_size || '—' }}</dd></div
                  >
                </dl>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, ref, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import { preorderListPropertiesApi, preorderListProductsApi } from '@/api/preorder/mat'
  import sdImage from '@/assets/images/ceremony/sd.png'
  import {
    cartTotalQty,
    loadPreorderCart,
    savePreorderCart,
    snapshotFromProduct,
    type PreorderCartLine
  } from './cartStorage'

  defineOptions({ name: 'PreorderCatalog' })

  type CategoryNode = { id: number | string; name: string }
  type ProductLike = Record<string, any>

  const router = useRouter()
  const loading = ref(true)
  const roots = ref<CategoryNode[]>([])
  const specsByParent = ref<Record<string, CategoryNode[]>>({})
  const products = ref<ProductLike[]>([])
  const cart = ref<Record<string, PreorderCartLine>>({})

  const activeRootId = ref('')
  const activeSpecId = ref('')

  const tokenConfigured = computed(() => Boolean(import.meta.env.VITE_PREORDER_API_TOKEN))
  const cartQty = computed(() => cartTotalQty(cart.value))

  const currentSpecs = computed(() => specsByParent.value[activeRootId.value] || [])

  const specSetByRoot = computed(() => {
    const m: Record<string, Set<string>> = {}
    Object.entries(specsByParent.value).forEach(([rid, list]) => {
      m[rid] = new Set(list.map((s) => String(s.id)))
    })
    return m
  })

  const filteredProducts = computed(() => {
    if (!products.value.length) return []
    const root = activeRootId.value
    if (!root) return products.value

    const set = specSetByRoot.value[root] || new Set<string>()
    const byRoot = products.value.filter((p) => set.has(String(p.category_id || '')))
    if (!activeSpecId.value) return byRoot
    return byRoot.filter((p) => String(p.category_id || '') === activeSpecId.value)
  })

  function imgUrl(row: ProductLike) {
    const u = row.image_url || row.logo
    if (!u) return sdImage
    if (String(u).startsWith('http')) return u
    return String(u).startsWith('/') ? u : `/${u}`
  }

  function isInCart(id: number | string) {
    return Boolean(cart.value[String(id)])
  }

  function toggleCart(row: ProductLike, checked: boolean) {
    const key = String(row.id)
    const next = { ...cart.value }
    if (checked) {
      const line = snapshotFromProduct(row)
      if (!next[key]) next[key] = line
      else next[key] = { ...next[key], ...line }
    } else {
      delete next[key]
    }
    cart.value = next
    savePreorderCart(next)
  }

  function scrollToCartHint() {
    ElMessage.info('勾选商品后，点击右上角「去下单」提交预购')
  }

  function goCheckout() {
    router.push({ name: 'PreorderCheckout' })
  }

  function goLogin() {
    router.push({ name: 'Login' })
  }

  function normalizeList(res: any): any[] {
    const raw = res?.data
    if (Array.isArray(raw)) return raw
    return raw?.list || raw?.data || raw?.records || []
  }

  async function loadRoots() {
    const res = await preorderListPropertiesApi({
      'q[sign_eq]': 'product_category',
      'q[parent_id_null]': true,
      per_page: 500
    })
    const list = normalizeList(res) as CategoryNode[]
    roots.value = list.sort((a, b) => String(a.name).localeCompare(String(b.name), 'zh-CN'))
    activeRootId.value = roots.value.length ? String(roots.value[0].id) : ''
  }

  async function loadSpecsForRoot(parentId: number | string) {
    const res = await preorderListPropertiesApi({
      'q[sign_eq]': 'product_category',
      'q[parent_id_eq]': parentId,
      per_page: 500
    })
    const list = normalizeList(res) as CategoryNode[]
    specsByParent.value[String(parentId)] = list.sort((a, b) =>
      String(a.name).localeCompare(String(b.name), 'zh-CN')
    )
  }

  async function loadAllProducts() {
    const all: ProductLike[] = []
    let page = 1
    const perPage = 200
    while (true) {
      const res = await preorderListProductsApi({ page, per_page: perPage })
      const chunk = normalizeList(res)
      all.push(...chunk)
      const total = (res as any).total ?? chunk.length
      if (all.length >= total || chunk.length === 0) break
      page += 1
      if (page > 200) break
    }
    products.value = all
  }

  watch(activeRootId, () => {
    activeSpecId.value = ''
  })

  onMounted(async () => {
    cart.value = loadPreorderCart()
    if (!tokenConfigured.value) {
      loading.value = false
      return
    }
    try {
      await loadRoots()
      await Promise.all(roots.value.map((r) => loadSpecsForRoot(r.id)))
      await loadAllProducts()
    } catch (e) {
      console.error(e)
    } finally {
      loading.value = false
    }
  })
</script>

<style scoped>
  .preorder-catalog {
    box-sizing: border-box;
    min-height: 100vh;
    padding: 16px 20px 32px;
    background: linear-gradient(180deg, #f7f8fa 0%, #fff 40%);
  }

  .preorder-header {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
    max-width: 1400px;
    padding: 12px 16px;
    margin: 0 auto 16px;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 12px;
    box-shadow: 0 2px 8px rgb(0 0 0 / 4%);
  }

  .preorder-title {
    margin: 0;
    font-size: 20px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  .preorder-sub {
    display: block;
    margin-top: 4px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .preorder-header-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
  }

  .preorder-badge :deep(.el-badge__content) {
    top: 4px;
    right: 18px;
  }

  .preorder-main {
    max-width: 1400px;
    min-height: 400px;
    padding: 8px 0;
    margin: 0 auto;
  }

  .filter-card {
    margin-bottom: 14px;
    border-radius: 12px;
  }

  .root-tabs {
    margin-bottom: 8px;
  }

  .spec-filter-wrap {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    padding: 4px 0 2px;
  }

  .spec-pill {
    padding: 6px 10px;
    font-size: 12px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 16px;
    transition: all 0.2s;
  }

  .spec-pill:hover {
    color: var(--el-color-primary);
    border-color: var(--el-color-primary-light-5);
  }

  .spec-pill.active {
    font-weight: 600;
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary-light-5);
  }

  .product-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 14px;
  }

  .product-cell {
    min-width: 0;
  }

  .product-card {
    position: relative;
    display: flex;
    flex-direction: column;
    height: 100%;
    padding: 10px;
    background: var(--el-fill-color-blank);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 10px;
    transition: box-shadow 0.2s;
  }

  .product-card:hover {
    box-shadow: 0 6px 16px rgb(0 0 0 / 6%);
  }

  .product-check {
    position: absolute;
    top: 8px;
    left: 8px;
    z-index: 2;
  }

  .product-media {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 132px;
    margin-bottom: 8px;
    background: linear-gradient(145deg, #f0f2f5, #e8ebef);
    border-radius: 8px;
  }

  .product-img {
    width: 100%;
    height: 100%;
  }

  .img-ph {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 12px;
    color: var(--el-text-color-placeholder);
  }

  .product-meta {
    padding-left: 2px;
  }

  .line-1 {
    display: flex;
    gap: 6px;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 2px;
  }

  .code {
    font-size: 15px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  .name {
    display: -webkit-box;
    margin-top: 2px;
    overflow: hidden;
    font-size: 13px;
    line-height: 1.35;
    color: var(--el-text-color-regular);
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  .details {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 6px 10px;
    padding-top: 8px;
    margin-top: 8px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .d-item {
    min-width: 0;
  }

  .d-item-full {
    grid-column: 1 / -1;
  }

  .d-item dt {
    margin: 0;
    font-size: 11px;
    color: var(--el-text-color-placeholder);
  }

  .d-item dd {
    margin: 2px 0 0;
    overflow: hidden;
    font-size: 12px;
    color: var(--el-text-color-regular);
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .spec-empty {
    grid-column: 1 / -1;
    padding: 24px 0;
    text-align: center;
    background: #fff;
    border: 1px dashed var(--el-border-color);
    border-radius: 10px;
  }
</style>
