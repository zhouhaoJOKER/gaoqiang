<!-- 产品详情页 -->
<template>
  <div class="product-detail-container">
    <div class="product-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <ElButton text class="star-btn" @click="handleToggleStar">
          <ArtSvgIcon
            :icon="productData.is_star ? 'ri:star-fill' : 'ri:star-line'"
            :class="{ 'is-starred': productData.is_star }"
          />
        </ElButton>
        <ElInput
          v-model="productData.name"
          class="header-name-input"
          placeholder="请输入产品名称"
          @blur="() => saveProductField('name', productData.name)"
        />
      </div>
      <div class="header-right">
        <div class="header-image">
          <ElImage
            :src="getImageUrl(productData.image_url, productData.logo)"
            fit="contain"
            class="header-image-img"
          >
            <template #error>
              <div class="image-placeholder">
                <ArtSvgIcon icon="ri:image-line" />
              </div>
            </template>
          </ElImage>
          <div class="header-upload-icon" @click="handleImageUploadClick">
            <ArtSvgIcon icon="ri:upload-2-line" />
          </div>
          <ImageUploadDialog ref="imageUploadDialogRef" @upload-success="handleLogoUploadSuccess" />
        </div>
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
      </div>
    </div>

    <div class="product-content-wrapper">
      <div class="product-detail-panel">
        <div class="boolean-row">
          <ElCheckbox v-model="productData.is_sale" @change="handleToggle('is_sale')">
            可销售
          </ElCheckbox>
          <ElCheckbox v-model="productData.is_purchase" @change="handleToggle('is_purchase')">
            可采购
          </ElCheckbox>
          <ElCheckbox v-model="productData.is_manufacture" @change="handleToggle('is_manufacture')">
            可生产
          </ElCheckbox>
          <ElCheckbox v-model="productData.is_stock" @change="handleToggle('is_stock')">
            可库存
          </ElCheckbox>
          <ElCheckbox v-model="productData.is_active" @change="handleToggle('is_active')">
            启用
          </ElCheckbox>
        </div>

        <div class="tab-bar">
          <div
            v-for="tab in tabs"
            :key="tab.key"
            class="tab-item"
            :class="{ active: activeProductTab === tab.key }"
            @click="activeProductTab = tab.key"
          >
            {{ tab.label }}
          </div>
        </div>

        <div class="tab-content">
          <component
            :is="currentTabComponent"
            v-if="currentTabComponent"
            v-bind="getTabProps(activeProductTab)"
            @save-field="saveProductField"
            @number-blur="handleNumberBlur"
            @combo-change="handleComboChange"
            @search-combos="searchCombos"
            @create-combo="handleCreateCombo"
          />
          <div v-else class="empty-tab">
            <div class="empty-text">该功能暂未实现</div>
          </div>
        </div>
      </div>
    </div>

    <div class="product-activity-panel">
      <div class="activity-header">活动</div>
      <div class="tabs-section">
        <ElTabs v-model="activeTab" class="activity-tabs">
          <ElTabPane label="所有动态" name="all" />
          <ElTabPane label="仅评论" name="comments" />
          <ElTabPane label="仅附件" name="attachments" />
        </ElTabs>
      </div>

      <div class="activity-list">
        <div v-for="(activity, index) in filteredActivities" :key="index" class="activity-item">
          <div class="activity-avatar">
            {{ getInitials(activity.user) }}
          </div>
          <div class="activity-body-content">
            <div class="activity-header-row">
              <div class="activity-title">
                <span class="activity-user">{{ activity.user }}</span>
                <span class="activity-action">{{ activity.action }}</span>
              </div>
              <div class="activity-time">{{ formatActivityTime(activity.time) }}</div>
            </div>
            <div
              v-if="activity.detail"
              class="activity-detail"
              v-html="sanitizeActivityDetail(activity.detail)"
            ></div>
          </div>
        </div>
      </div>

      <div class="comment-section">
        <div class="comment-input">
          <div class="comment-editor-wrapper">
            <ArtWangEditor
              v-model="commentText"
              :height="'80px'"
              placeholder="请输入评论..."
              :toolbar-keys="[
                'emotion',
                'bold',
                'italic',
                '|',
                'bulletedList',
                'numberedList',
                '|',
                'undo',
                'redo'
              ]"
              class="comment-editor"
            />
          </div>
          <div class="comment-actions">
            <ElButton type="primary" size="small" class="reply-btn" @click="handleSendComment">
              回复
            </ElButton>
          </div>
        </div>
      </div>
    </div>

    <!-- 组合创建对话框 -->
    <ComboDialog v-model="comboDialogVisible" @created="handleComboCreated" />
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtWangEditor from '@/components/core/forms/art-wang-editor/index.vue'
  import ImageUploadDialog from '@/components/ImageUploadDialog.vue'
  import ComboDialog from './modules/combo-dialog.vue'
  import TabGeneral from './modules/tab-general.vue'
  import TabAttributes from './modules/tab-attributes.vue'
  import TabSales from './modules/tab-sales.vue'
  import TabPos from './modules/tab-pos.vue'
  import TabPrices from './modules/tab-prices.vue'
  import TabPurchase from './modules/tab-purchase.vue'
  import TabInventory from './modules/tab-inventory.vue'
  import TabAccounting from './modules/tab-accounting.vue'
  import TabEcommerce from './modules/tab-ecommerce.vue'
  import TabCombo from './modules/tab-combo.vue'
  import { listActivityApi, createActivityApi } from '@/api/activity'
  import {
    viewMatProductApi,
    updateMatProductApi,
    listMatProductComboApi,
    viewMatProductComboApi
  } from '@/api/mat/product'
  import sdImage from '@/assets/images/ceremony/sd.png'
  import { ElButton, ElInput, ElImage, ElCheckbox, ElTabs, ElTabPane } from 'element-plus'

  defineOptions({ name: 'MatProductDetail' })

  const baseTabs = [
    { key: 'general', label: '基础信息' },
    { key: 'attributes', label: '属性和变体' },
    { key: 'sales', label: 'Sales' },
    { key: 'pos', label: 'Point of Sale' },
    { key: 'prices', label: 'Prices' },
    { key: 'purchase', label: 'Purchase' },
    { key: 'inventory', label: 'Inventory' },
    { key: 'accounting', label: 'Accounting' },
    { key: 'ecommerce', label: 'eCommerce' }
  ]

  const tabs = computed(() => {
    if (productData.type_id === 2) {
      // 组合类型：隐藏「属性和变体」页签，在 general 之后插入「产品组合」页签
      const result = baseTabs.filter((t) => t.key !== 'attributes')
      const generalIndex = result.findIndex((t) => t.key === 'general')
      result.splice(generalIndex + 1, 0, { key: 'combo', label: '产品组合' })
      return result
    }
    return baseTabs
  })

  const activeProductTab = ref('general')

  // Tab组件映射
  const tabComponents: Record<string, any> = {
    general: TabGeneral,
    attributes: TabAttributes,
    sales: TabSales,
    pos: TabPos,
    prices: TabPrices,
    purchase: TabPurchase,
    inventory: TabInventory,
    accounting: TabAccounting,
    ecommerce: TabEcommerce,
    combo: TabCombo
  }

  // 当前tab组件
  const currentTabComponent = computed(() => {
    return tabComponents[activeProductTab.value]
  })

  // 获取tab的props
  const getTabProps = (tabKey: string): Record<string, any> => {
    const baseProps: Record<string, any> = {
      productData
    }

    if (tabKey === 'general') {
      return {
        ...baseProps,
        comboOptions: comboOptions.value,
        comboSearchLoading: comboSearchLoading.value
      }
    } else if (tabKey === 'combo') {
      return {
        comboDetail: comboDetail.value,
        comboDetailLoading: comboDetailLoading.value
      }
    }

    return baseProps
  }

  const route = useRoute()
  const router = useRouter()

  const handleGoBack = (): void => {
    router.back()
  }

  const productId = computed(() => {
    const id = route.params.id || route.query.id
    return Array.isArray(id) ? id[0] : id
  })

  interface ProductData {
    id?: string | number
    user_id?: string | number
    updater_id?: string | number
    company_id?: string | number
    name: string
    logo?: string
    image_url?: string
    code?: string
    py?: string
    pinyin?: string
    type_id?: string | number
    category_id?: string | number
    parent_category_id?: string | number
    parent_category_name?: string
    price?: number | string
    cost_price?: number | string
    market_price?: number | string
    description?: string
    material?: string
    full_capacity?: string
    nominal_capacity?: string
    gram_weight?: string
    caliber?: string
    cap_height?: string
    max_diameter?: string
    label_size?: string
    uom_id?: string | number
    uom_po_id?: string | number
    sale_tax_id?: string | number
    purchase_tax_id?: string | number
    is_sale?: boolean
    is_purchase?: boolean
    is_manufacture?: boolean
    is_stock?: boolean
    is_active?: boolean
    is_star?: boolean
    combo_id?: string | number
    track_inventory?: boolean
    track_inventory_type?: string
    on_hand_quantity?: number | string
    [key: string]: any
  }

  const productData = reactive<ProductData>({
    id: undefined,
    user_id: undefined,
    updater_id: undefined,
    company_id: undefined,
    name: '',
    logo: '',
    image_url: '',
    code: '',
    py: '',
    pinyin: '',
    type_id: 1,
    category_id: undefined,
    parent_category_id: undefined,
    parent_category_name: '',
    price: undefined,
    cost_price: undefined,
    market_price: undefined,
    description: '',
    material: '',
    full_capacity: '',
    nominal_capacity: '',
    gram_weight: '',
    caliber: '',
    cap_height: '',
    max_diameter: '',
    label_size: '',
    uom_id: undefined,
    uom_po_id: undefined,
    sale_tax_id: undefined,
    purchase_tax_id: undefined,
    is_sale: true,
    is_purchase: true,
    is_manufacture: false,
    is_stock: true,
    is_active: true,
    is_star: false,
    combo_id: undefined,
    track_inventory: false,
    track_inventory_type: 'quantity',
    on_hand_quantity: 0
  })

  const activeTab = ref('all')
  const commentText = ref('')
  const activities = ref<
    Array<{
      user: string
      action: string
      detail?: string
      time: string
      type: 'all' | 'comments' | 'attachments'
    }>
  >([])

  // 组合相关
  const comboOptions = ref<any[]>([])
  const comboSearchLoading = ref(false)
  const comboDialogVisible = ref(false)

  // 组合详情
  const comboDetail = ref<any>(null)
  const comboDetailLoading = ref(false)
  /** 已持久化的组合 ID，用于组合类型下清空时恢复 */
  const lastSavedComboId = ref<string | number | undefined>(undefined)

  const filteredActivities = computed(() => {
    if (activeTab.value === 'all') {
      return activities.value
    }
    return activities.value.filter((a) => a.type === activeTab.value)
  })

  const handleRefresh = (): void => {
    loadProductDetail()
  }

  const loadProductDetail = async (): Promise<void> => {
    if (!productId.value) {
      ElMessage.warning('产品ID不存在')
      return
    }
    try {
      const res = await viewMatProductApi({ id: productId.value })
      const data = (res as any).data || {}
      // 确保 type_id 是数字类型
      if (data.type_id !== undefined && data.type_id !== null) {
        data.type_id = Number(data.type_id)
      }
      Object.assign(productData, data)
      lastSavedComboId.value = productData.combo_id
      await loadActivities()
      // 如果选择了组合，加载组合详情
      if (productData.type_id === 2 && productData.combo_id) {
        await loadComboDetail()
      }
    } catch (error) {
      console.error('加载产品详情失败:', error)
      ElMessage.error('加载产品详情失败')
    }
  }

  // 加载组合详情
  const loadComboDetail = async (): Promise<void> => {
    if (!productData.combo_id) {
      comboDetail.value = null
      return
    }
    comboDetailLoading.value = true
    try {
      const res = await viewMatProductComboApi({ id: productData.combo_id })
      comboDetail.value = (res as any).data || null
    } catch (error) {
      console.error('加载组合详情失败:', error)
      comboDetail.value = null
    } finally {
      comboDetailLoading.value = false
    }
  }

  const saveProductField = async (
    field: string,
    value: any,
    field2?: string,
    value2?: any
  ): Promise<void> => {
    if (!productData.id) return
    // 组合类型：必须选择组合才可提交更新（combo_id 清空由 handleComboChange 拦截并恢复）
    if (productData.type_id === 2 && field !== 'type_id') {
      if (!productData.combo_id) {
        ElMessage.warning('请先选择产品组合后再保存')
        return
      }
    }
    const prev: Record<string, any> = { [field]: (productData as any)[field] }
    if (field2 !== undefined) prev[field2] = (productData as any)[field2]
    try {
      // 乐观更新：先更新本地，再请求接口；失败时回滚
      ;(productData as any)[field] = value
      if (field2 !== undefined && value2 !== undefined) {
        ;(productData as any)[field2] = value2
      }
      const updateData: Record<string, any> = { [field]: value }
      if (field2 !== undefined && value2 !== undefined) {
        updateData[field2] = value2
      }
      const res = await updateMatProductApi(String(productData.id), updateData)
      const data = (res as any)?.data
      if (data && typeof data === 'object') {
        Object.assign(productData, data)
      }
      if (field === 'combo_id') {
        lastSavedComboId.value = value
      }
      ElMessage.success('保存成功')
    } catch (error) {
      console.error(`保存${field}失败:`, error)
      ElMessage.error('保存失败')
      ;(productData as any)[field] = prev[field]
      if (field2 !== undefined && prev[field2] !== undefined) {
        ;(productData as any)[field2] = prev[field2]
      }
    }
  }

  const handleNumberBlur = (field: keyof ProductData): void => {
    const num = Number(productData[field])
    const value = Number.isNaN(num) ? 0 : num
    productData[field] = value
    saveProductField(String(field), value)
  }

  const handleToggle = (field: string): void => {
    const value = productData[field as keyof ProductData]
    saveProductField(field, value)
  }

  const handleToggleStar = async (): Promise<void> => {
    productData.is_star = !productData.is_star
    await saveProductField('is_star', productData.is_star)
  }

  const imageUploadDialogRef = ref<{ openDialog: () => void } | null>(null)

  const handleImageUploadClick = (): void => {
    if (imageUploadDialogRef.value?.openDialog) {
      imageUploadDialogRef.value.openDialog()
    } else {
      ElMessage.warning('上传组件未初始化')
    }
  }

  const handleLogoUploadSuccess = async (url: string): Promise<void> => {
    if (!url) {
      ElMessage.warning('上传失败，未获取到图片地址')
      return
    }
    productData.logo = url
    productData.image_url = url
    await saveProductField('image_url', url, 'logo', url)
  }

  const getImageUrl = (imageUrl: string | undefined, logo: string | undefined): string => {
    const finalUrl = imageUrl || logo
    if (!finalUrl) return sdImage
    if (finalUrl.startsWith('http://') || finalUrl.startsWith('https://')) {
      return finalUrl
    }
    return finalUrl.startsWith('/') ? finalUrl : `/${finalUrl}`
  }

  const loadActivities = async (): Promise<void> => {
    if (!productId.value) return
    try {
      const res = await listActivityApi(
        {
          'q[record_type_eq]': 'Product',
          'q[record_id_eq]': productId.value
        },
        { showErrorMessage: false }
      )
      const data = (res as any).data || {}
      const activityList = Array.isArray(data) ? data : data.list || data.data || data.records || []

      activities.value = activityList.map((item: any) => {
        let activityType: 'all' | 'comments' | 'attachments' = 'all'
        if (item.type === 'comment') {
          activityType = 'comments'
        } else if (item.type === 'attachment') {
          activityType = 'attachments'
        }
        return {
          user: item.user_name || item.user_email || '未知用户',
          action: item.action || '评论',
          detail: item.content || item.description,
          time: item.created_at || item.created_time,
          type: activityType
        }
      })
    } catch (error) {
      console.error('加载活动列表失败:', error)
      activities.value = [
        {
          user: '系统',
          action: '创建了产品',
          time: new Date().toISOString(),
          type: 'all'
        }
      ]
    }
  }

  // 搜索组合
  const searchCombos = async (query: string): Promise<void> => {
    comboSearchLoading.value = true
    try {
      const res = await listMatProductComboApi({
        'q[name_or_py_cont]': query || '',
        per_page: 20
      })
      comboOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索组合失败:', error)
      comboOptions.value = []
    } finally {
      comboSearchLoading.value = false
    }
  }

  // 处理组合变化
  const handleComboChange = async (comboId: string | number | undefined): Promise<void> => {
    const isEmpty = comboId === undefined || comboId === null || comboId === ''
    if (productData.type_id === 2 && isEmpty) {
      productData.combo_id = lastSavedComboId.value
      ElMessage.warning('请选择产品组合，已恢复原选择')
      return
    }
    // 组合类型下选择组合时，先持久化 type_id 再持久化 combo_id（点到组合时未保存 type_id）
    if (productData.type_id === 2 && comboId) {
      await saveProductField('type_id', 2)
    }
    await saveProductField('combo_id', comboId)
    if (comboId) {
      await loadComboDetail()
    } else {
      comboDetail.value = null
    }
  }

  // 创建组合
  const handleCreateCombo = (): void => {
    comboDialogVisible.value = true
  }

  // 初始化时加载组合列表
  watch(
    () => productData.type_id,
    (val) => {
      if (val === 2) {
        searchCombos('')
        // 组合类型不显示属性和变体页签，若当前在此页签则切到产品组合
        if (activeProductTab.value === 'attributes') {
          activeProductTab.value = 'combo'
        }
      }
    },
    { immediate: true }
  )

  // 组合创建成功回调
  const handleComboCreated = async (combo: any): Promise<void> => {
    searchCombos('')
    if (combo && combo.id) {
      productData.combo_id = combo.id
      if (productData.type_id === 2) {
        await saveProductField('type_id', 2)
      }
      await saveProductField('combo_id', combo.id)
      await loadComboDetail()
    }
  }

  const handleSendComment = async (): Promise<void> => {
    if (!commentText.value.trim()) {
      ElMessage.warning('请输入评论内容')
      return
    }
    if (!productId.value) {
      ElMessage.warning('产品ID不存在')
      return
    }
    try {
      await createActivityApi({
        record_type: 'Product',
        record_id: productId.value,
        type: 'comment',
        content: commentText.value
      })
      ElMessage.success('评论发送成功')
      commentText.value = ''
      await loadActivities()
    } catch (error) {
      console.error('发送评论失败:', error)
      ElMessage.error('发送评论失败')
    }
  }

  const sanitizeActivityDetail = (html: string): string => {
    if (!html) return ''
    const container = document.createElement('div')
    container.innerHTML = html
    const unsafeNodes = container.querySelectorAll('script, style, iframe, object, embed')
    unsafeNodes.forEach((node) => node.remove())
    const allNodes = container.querySelectorAll('*')
    allNodes.forEach((node) => {
      Array.from(node.attributes).forEach((attr) => {
        const name = attr.name.toLowerCase()
        const value = attr.value?.toLowerCase() || ''
        if (name.startsWith('on')) {
          node.removeAttribute(attr.name)
        }
        if ((name === 'href' || name === 'src') && value.startsWith('javascript:')) {
          node.removeAttribute(attr.name)
        }
      })
    })
    return container.innerHTML
  }

  const formatActivityTime = (timeStr: string): string => {
    const date = new Date(timeStr)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')

    if (diffDays === 0) {
      return `${month}月${day}日 ${hours}:${minutes}`
    } else if (diffDays === 1) {
      return `昨天 ${hours}:${minutes}`
    } else if (diffDays < 7) {
      return `${diffDays}天前 ${hours}:${minutes}`
    }
    return `${year}年${month}月${day}日 ${hours}:${minutes}`
  }

  const getInitials = (name?: string): string => {
    if (!name) return '?'
    return name.substring(0, 1).toUpperCase()
  }

  onMounted(() => {
    loadProductDetail()
    searchCombos('')
  })
</script>

<style scoped lang="scss">
  .product-detail-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: 100vh;
    overflow-y: auto;
    background: #fff;
  }

  .product-header-bar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding: 12px 20px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .header-left {
      display: flex;
      gap: 12px;
      align-items: center;

      .back-btn {
        padding: 6px;
        font-size: 18px;
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }
      }

      .star-btn {
        padding: 6px;
        font-size: 18px;
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }

        .is-starred {
          color: #f5b400;
        }
      }

      .header-name-input {
        min-width: 280px;

        :deep(.el-input__wrapper) {
          padding-left: 0;
          border: 1px solid transparent;
          box-shadow: none;
        }

        :deep(.el-input__inner) {
          font-size: 18px;
          font-weight: 600;
          color: var(--el-text-color-primary);
        }

        :deep(.el-input__wrapper.is-focus) {
          border-color: var(--el-border-color);
          box-shadow: none;
        }
      }
    }

    .header-right {
      display: flex;
      gap: 8px;
      align-items: center;

      .header-image {
        position: relative;
        width: 56px;
        height: 56px;
        padding: 6px;
        background: var(--el-fill-color-light);
        border-radius: 6px;
      }

      .header-image-img {
        width: 100%;
        height: 100%;
      }

      .header-upload-icon {
        position: absolute;
        right: 4px;
        bottom: 4px;
        z-index: 10;
        display: none;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        font-size: 14px;
        color: #fff;
        cursor: pointer;
        background: rgb(0 0 0 / 60%);
        border-radius: 4px;
        transition: all 0.2s;

        &:hover {
          background: rgb(0 0 0 / 80%);
          transform: scale(1.1);
        }
      }

      .header-image:hover .header-upload-icon {
        display: flex;
      }

      .header-upload-hidden {
        display: none;
      }

      .header-upload {
        position: absolute;
        right: -4px;
        bottom: -4px;
        transform: scale(0.75);
        transform-origin: bottom right;
      }

      .header-action-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }
    }
  }

  .product-content-wrapper {
    flex-shrink: 0;
  }

  .product-detail-panel {
    padding: 24px;
  }

  .boolean-row {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    justify-content: center;
    padding-bottom: 8px;
    margin-bottom: 8px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .tab-bar {
    display: flex;
    gap: 16px;
    padding-bottom: 12px;
    margin-bottom: 16px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .tab-item {
    padding: 6px 8px;
    font-size: 14px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: all 0.2s;
  }

  .tab-item.active {
    font-weight: 500;
    color: var(--el-color-primary);
    border-bottom-color: var(--el-color-primary);
  }

  .tab-content {
    min-height: 200px;
  }

  .fields-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }

  .fields-column {
    display: flex;
    flex-direction: column;
  }

  .general-aside {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .empty-tab {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 240px;
    color: var(--el-text-color-placeholder);
  }

  .empty-text {
    font-size: 14px;
  }

  .section-block {
    padding-bottom: 20px;
    margin-bottom: 20px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    &:last-child {
      border-bottom: none;
    }
  }

  .section-title {
    margin-bottom: 16px;
    font-size: 15px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .field-row {
    display: flex;
    gap: 16px;
    align-items: center;
    margin-bottom: 14px;

    .field-label {
      width: 90px;
      font-size: 13px;
      color: var(--el-text-color-regular);
    }

    .field-value {
      flex: 1;
    }
  }

  .toggle-row {
    align-items: center;
    justify-content: space-between;
  }

  .image-card {
    .image-wrapper {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 200px;
      background: var(--el-fill-color-light);
      border-radius: 8px;
    }

    .product-image {
      width: 100%;
      height: 100%;
    }
  }

  .image-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 28px;
    color: var(--el-text-color-placeholder);
  }

  .meta-card {
    .meta-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 8px 0;
      font-size: 13px;
      color: var(--el-text-color-regular);

      .meta-label {
        color: var(--el-text-color-secondary);
      }

      .meta-value {
        font-weight: 500;
        color: var(--el-text-color-primary);
      }
    }
  }

  .product-activity-panel {
    display: flex;
    flex-direction: column;
    width: 100%;
    padding: 24px;
    background: #fff;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .activity-header {
    padding-bottom: 8px;
    margin-bottom: 12px;
    font-size: 15px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .tabs-section {
    margin-bottom: 16px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .activity-list {
    padding: 8px 0 16px;
  }

  .activity-item {
    display: flex;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--el-border-color-lighter);

    &:last-child {
      border-bottom: none;
    }
  }

  .activity-avatar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 12px;
    font-weight: 500;
    color: #fff;
    background: #f3b16b;
    border-radius: 50%;
  }

  .activity-body-content {
    flex: 1;
    min-width: 0;
  }

  .activity-header-row {
    display: flex;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
  }

  .activity-title {
    display: flex;
    gap: 6px;
    align-items: center;
    min-width: 0;
  }

  .activity-user {
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .activity-action {
    color: var(--el-text-color-regular);
  }

  .activity-time {
    font-size: 12px;
    color: var(--el-text-color-placeholder);
    white-space: nowrap;
  }

  .activity-detail {
    margin-top: 4px;
    line-height: 1.5;
    color: var(--el-text-color-regular);
    word-break: break-word;
  }

  .comment-section {
    padding-top: 16px;
    margin-top: 16px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  @media (width <= 1200px) {
    .fields-grid {
      grid-template-columns: 1fr;
    }
  }

  .comment-actions {
    display: flex;
    justify-content: flex-end;
    padding: 6px 0 0;
  }

  .combo-option-footer {
    display: flex;
    gap: 8px;
    justify-content: center;
    padding: 8px 0;
  }

  .category-select-wrapper {
    width: 100%;
  }

  .category-option-footer {
    display: flex;
    gap: 8px;
    justify-content: center;
    padding: 8px 0;
  }

  .combo-tab {
    padding: 24px;
  }

  .combo-detail {
    .section-block {
      margin-bottom: 24px;
    }

    .section-title {
      margin-bottom: 16px;
      font-size: 15px;
      font-weight: 500;
      color: var(--el-text-color-primary);
    }

    .field-row {
      display: flex;
      gap: 16px;
      align-items: center;
      margin-bottom: 14px;

      .field-label {
        flex-shrink: 0;
        width: 120px;
        font-size: 14px;
        color: var(--el-text-color-regular);
      }

      .field-value {
        flex: 1;
        font-size: 14px;
        color: var(--el-text-color-primary);
      }
    }
  }
</style>
