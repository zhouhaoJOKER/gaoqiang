<!-- 产品列表页面 -->
<template>
  <div class="product-page art-full-height">
    <div class="flex flex-shrink-0 items-center justify-between mb-3">
      <div class="flex items-center gap-3">
        <span class="text-base font-medium text-g-900">产品</span>
      </div>
      <div class="flex items-center gap-2">
        <div class="view-switch">
          <ElButton
            :type="viewMode === 'list' ? 'primary' : 'default'"
            text
            @click="viewMode = 'list'"
          >
            <ArtSvgIcon icon="ri:list-check" class="mr-1" />
            列表
          </ElButton>
          <ElButton
            :type="viewMode === 'card' ? 'primary' : 'default'"
            text
            @click="viewMode = 'card'"
          >
            <ArtSvgIcon icon="ri:apps-line" class="mr-1" />
            卡片
          </ElButton>
        </div>
        <ElDropdown trigger="click">
          <ElButton type="default" v-ripple>
            <ArtSvgIcon icon="ri:more-2-line" />
            更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
          </ElButton>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem @click="showBatchAddDialog">
                <ArtSvgIcon class="el-icon--left" icon="ri:add-circle-line" />
                批量添加
              </ElDropdownItem>
              <ElDropdownItem @click="showBatchEditDialog">
                <ArtSvgIcon class="el-icon--left" icon="ri:edit-box-line" />
                批量编辑
              </ElDropdownItem>
              <ElDropdownItem @click="handleBatchDelete">
                <ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                批量删除
              </ElDropdownItem>
              <ElDropdownItem divided></ElDropdownItem>
              <ElDropdownItem @click="handleExport">
                <ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                导出
              </ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
        <ElButton type="primary" @click="handleCreate">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建产品
        </ElButton>
      </div>
    </div>

    <ArtSearchBar
      v-model="formFilters"
      :items="formItems"
      :showExpand="false"
      class="mb-1 flex-shrink-0"
      @reset="handleReset"
      @search="handleSearch"
    />

    <div class="product-page-body">
      <ElCard v-if="viewMode === 'list'" class="art-table-card" shadow="never">
        <ArtTableHeader
          :showZebra="false"
          :loading="loading"
          v-model:columns="columnChecks"
          @refresh="handleRefresh"
        />
        <ArtTable
          ref="proTable"
          rowKey="id"
          :loading="loading"
          :columns="columns"
          :data="filteredTableData"
          :stripe="false"
          @selection-change="handleSelectionChange"
        />
        <div class="pagination-wrapper">
          <ElPagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </ElCard>

      <div v-else class="card-view" v-loading="sidebarLoading && !rootCategories.length">
        <div class="category-layout">
          <aside class="category-sidebar">
            <div class="sidebar-title">产品分类</div>
            <div v-if="!rootCategories.length && !sidebarLoading" class="sidebar-empty">
              暂无大类数据
            </div>
            <div v-for="root in rootCategories" :key="root.id" class="category-section">
              <div
                class="category-header"
                :class="{ active: selectedParentId === root.id }"
                @click="onToggleRoot(root)"
              >
                <span class="category-name">{{ root.name }}</span>
                <ArtSvgIcon
                  icon="ri:arrow-down-s-line"
                  class="category-arrow"
                  :class="{ expanded: expandedRootId === root.id }"
                />
              </div>
              <div v-if="expandedRootId === root.id" class="capacity-panel">
                <div v-if="specsLoadingId === root.id" class="specs-loading">加载规格中…</div>
                <div v-else class="capacity-grid">
                  <button
                    type="button"
                    class="capacity-item"
                    :class="{
                      active: selectedParentId === root.id && selectedSpecId == null
                    }"
                    @click="onSelectAllSpecs(root.id)"
                  >
                    全部
                  </button>
                  <button
                    v-for="spec in specsByParentId[String(root.id)] || []"
                    :key="spec.id"
                    type="button"
                    class="capacity-item"
                    :class="{
                      active: selectedParentId === root.id && selectedSpecId === spec.id
                    }"
                    @click="onSelectSpec(root.id, spec.id)"
                  >
                    {{ spec.name }}
                  </button>
                </div>
              </div>
            </div>
          </aside>

          <section class="category-products">
            <div class="products-toolbar">
              <div class="toolbar-info">
                <template v-if="selectedParentId != null">
                  <span class="toolbar-label">当前筛选</span>
                  <ElTag size="small" type="info" effect="light">{{ currentFilterLabel }}</ElTag>
                  <span class="toolbar-count">共 {{ pagination.total }} 件</span>
                  <ElButton type="primary" link class="toolbar-clear" @click="clearCategoryFilter">
                    显示全部产品
                  </ElButton>
                </template>
                <template v-else>
                  <span class="toolbar-label">全部产品</span>
                  <span class="toolbar-count">共 {{ pagination.total }} 件</span>
                  <span class="toolbar-hint">左侧可选大类或规格，缩小展示范围</span>
                </template>
              </div>
            </div>

            <div class="product-cards-scroll" v-loading="loading">
              <div class="product-card-grid">
                <template v-if="!loading && !tableData.length">
                  <div class="products-empty">
                    <ArtSvgIcon icon="ri:inbox-line" class="empty-icon" />
                    <p>{{ selectedParentId != null ? '该条件下暂无产品' : '暂无产品数据' }}</p>
                  </div>
                </template>
                <template v-else>
                  <ElCard
                    v-for="item in tableData"
                    :key="item.id"
                    class="product-card"
                    shadow="hover"
                    @click="handleProductClick(item)"
                  >
                    <div class="product-card-inner">
                      <div class="card-media">
                        <ElImage
                          :src="getImageUrl(item.image_url, item.logo)"
                          fit="contain"
                          class="card-image"
                        >
                          <template #error>
                            <div class="image-placeholder">
                              <ArtSvgIcon icon="ri:image-line" />
                            </div>
                          </template>
                        </ElImage>
                        <button
                          type="button"
                          class="card-detail-btn"
                          title="查看详情"
                          @click.stop="handleProductClick(item)"
                        >
                          <ArtSvgIcon icon="ri:arrow-right-circle-line" />
                        </button>
                      </div>
                      <div class="card-content">
                        <div class="card-code">{{ item.code || '—' }}</div>
                        <div class="card-name">{{ item.name || '未命名产品' }}</div>
                        <div class="card-tags">
                          <ElTag
                            v-if="item.category_name"
                            size="small"
                            effect="plain"
                            type="primary"
                          >
                            {{ item.category_name }}
                          </ElTag>
                          <ElTag v-if="item.material" size="small" effect="plain">{{
                            item.material
                          }}</ElTag>
                        </div>
                        <dl class="card-specs">
                          <div class="spec-row">
                            <dt>公称容量</dt>
                            <dd>{{ item.nominal_capacity || '—' }}</dd>
                          </div>
                          <div class="spec-row">
                            <dt>满口容量</dt>
                            <dd>{{ item.full_capacity || '—' }}</dd>
                          </div>
                          <div class="spec-row">
                            <dt>口径</dt>
                            <dd>{{ item.caliber || '—' }}</dd>
                          </div>
                          <div class="spec-row">
                            <dt>带盖高度</dt>
                            <dd>{{ item.cap_height || '—' }}</dd>
                          </div>
                          <div class="spec-row">
                            <dt>最大直径</dt>
                            <dd>{{ item.max_diameter || '—' }}</dd>
                          </div>
                          <div class="spec-row spec-row-full">
                            <dt>贴标尺寸</dt>
                            <dd>{{ item.label_size || '—' }}</dd>
                          </div>
                        </dl>
                      </div>
                    </div>
                  </ElCard>
                </template>
              </div>
            </div>
          </section>
        </div>

        <div class="pagination-wrapper pagination-wrapper--card">
          <ElPagination
            v-model:current-page="pagination.page"
            v-model:page-size="pagination.pageSize"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </div>
    </div>

    <ElDialog
      v-model="createDialogVisible"
      title="新建产品"
      width="520px"
      :close-on-click-modal="false"
    >
      <ElForm :model="createForm" label-width="88px">
        <ElFormItem label="名称">
          <ElInput v-model="createForm.name" placeholder="请输入产品名称" />
        </ElFormItem>
        <ElFormItem label="类型">
          <ElRadioGroup v-model="createForm.type_id">
            <ElRadio :label="0">服务</ElRadio>
            <ElRadio :label="1">实物</ElRadio>
            <ElRadio :label="2">结合</ElRadio>
          </ElRadioGroup>
        </ElFormItem>
        <ElFormItem label="产品大类">
          <PropertySelectWithAdd
            v-model="createForm.parent_category_id"
            sign="product_category"
            placeholder="请选择产品大类"
            :root-only="true"
            @change="() => (createForm.category_id = undefined)"
          />
        </ElFormItem>
        <ElFormItem label="规格">
          <PropertySelectWithAdd
            v-model="createForm.category_id"
            sign="product_category"
            placeholder="请先选择大类"
            :parent-id-eq="createForm.parent_category_id"
            :disabled="!createForm.parent_category_id"
          />
        </ElFormItem>
        <ElFormItem label="金额">
          <ElInput v-model="createForm.price" type="number" placeholder="0.00" />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="createDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="createLoading" @click="handleCreateSubmit">
          创建
        </ElButton>
      </template>
    </ElDialog>

    <!-- 批量添加弹窗 -->
    <ProductBatchAddDialog v-model="batchAddDialogVisible" @success="handleBatchAddSuccess" />

    <!-- 批量编辑弹窗 -->
    <ProductBatchEditDialog
      v-model="batchEditDialogVisible"
      :selectedRows="selectedRows"
      @success="handleBatchEditSuccess"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref, reactive, computed, onMounted, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import {
    ElButton,
    ElCard,
    ElDialog,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElForm,
    ElFormItem,
    ElIcon,
    ElImage,
    ElInput,
    ElMessage,
    ElMessageBox,
    ElPagination,
    ElRadioGroup,
    ElRadio,
    ElTag,
    ElTooltip
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import {
    createMatProductApi,
    listMatProductApi,
    batchActionMatProductApi
  } from '@/api/mat/product'
  import { listPropertyApi } from '@/api/property'
  import { exportExcel } from '@/utils/tool/toExcel'
  import sdImage from '@/assets/images/ceremony/sd.png'
  import ProductBatchAddDialog from './modules/product-batch-add-dialog.vue'
  import ProductBatchEditDialog from './modules/product-batch-edit-dialog.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  defineOptions({ name: 'MatProducts' })

  const router = useRouter()

  interface ProductItem {
    id?: string | number
    name?: string
    logo?: string
    image_url?: string
    code?: string
    type_id?: string | number
    type_name?: string
    category_id?: string | number
    category_name?: string
    parent_category_id?: string | number
    parent_category_name?: string
    price?: number | string
    cost_price?: number | string
    market_price?: number | string
    description?: string
    material?: string
    full_capacity?: string
    nominal_capacity?: string
    caliber?: string
    cap_height?: string
    max_diameter?: string
    label_size?: string
    is_sale?: boolean
    is_purchase?: boolean
    is_manufacture?: boolean
    is_stock?: boolean
    is_active?: boolean
    [key: string]: any
  }

  const loading = ref(false)
  const viewMode = ref<'list' | 'card'>('card')
  const createDialogVisible = ref(false)
  const createLoading = ref(false)
  const proTable = ref()
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })

  interface CategoryNode {
    id: number | string
    name: string
  }

  const rootCategories = ref<CategoryNode[]>([])
  const sidebarLoading = ref(false)
  const specsByParentId = reactive<Record<string, CategoryNode[]>>({})
  const specsLoaded = reactive<Record<string, boolean>>({})
  const specsLoadingId = ref<number | string | null>(null)
  const expandedRootId = ref<number | string | null>(null)
  /** 卡片模式：选中的大类 id；点击「全部」或规格后再请求产品 */
  const selectedParentId = ref<number | string | null>(null)
  const selectedSpecId = ref<number | string | null>(null)

  // 批量操作相关
  const batchAddDialogVisible = ref(false)
  const batchEditDialogVisible = ref(false)
  const selectedRows = ref<ProductItem[]>([])

  const createForm = reactive({
    parent_category_id: undefined as string | number | undefined,
    category_id: undefined as string | number | undefined,
    type_id: 1 as number,
    name: '',
    price: ''
  })

  const initialSearchState = {
    name: '',
    code: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '名称',
      key: 'name',
      type: 'input',
      props: { clearable: true, placeholder: '请输入产品名称' }
    },
    {
      label: '编码',
      key: 'code',
      type: 'input',
      props: { clearable: true, placeholder: '请输入产品编码' }
    }
  ])

  const tableData = ref<ProductItem[]>([])

  const { columnChecks, columns } = useTableColumns(() => [
    { type: 'selection' }, // 勾选列
    {
      prop: 'name',
      label: '名称',
      minWidth: 200,
      formatter: (row: ProductItem) => {
        return h('div', { class: 'flex items-center gap-2' }, [
          h(
            'span',
            {
              class: 'cursor-pointer hover:text-primary-500 transition-colors',
              onClick: () => handleProductClick(row)
            },
            row.name || ''
          ),
          row.code
            ? h(
                ElTooltip,
                { content: `编码：${row.code}`, placement: 'top' },
                {
                  default: () => h('span', { class: 'text-xs text-g-400' }, `[${row.code}]`)
                }
              )
            : null
        ])
      }
    },
    {
      prop: 'category_name',
      label: '大类 / 规格',
      minWidth: 200,
      formatter: (row: ProductItem) => {
        const major = row.parent_category_name || row.category_name || '未设置'
        const spec =
          row.parent_category_name &&
          row.category_name &&
          row.parent_category_name !== row.category_name
            ? row.category_name
            : ''
        return spec ? `${major} / ${spec}` : major
      }
    },
    {
      prop: 'nominal_capacity',
      label: '公称容量',
      minWidth: 120,
      formatter: (row: ProductItem) => row.nominal_capacity || '未设置'
    },
    {
      prop: 'material',
      label: '材质',
      minWidth: 120,
      formatter: (row: ProductItem) => row.material || '-'
    },
    {
      prop: 'caliber',
      label: '口径',
      minWidth: 100,
      formatter: (row: ProductItem) => row.caliber || '-'
    },
    {
      prop: 'cap_height',
      label: '带盖高度',
      minWidth: 120,
      formatter: (row: ProductItem) => row.cap_height || '-'
    },
    {
      prop: 'max_diameter',
      label: '最大直径',
      minWidth: 140,
      formatter: (row: ProductItem) => row.max_diameter || '-'
    },
    {
      prop: 'is_active',
      label: '状态',
      minWidth: 100,
      formatter: (row: ProductItem) =>
        h(
          ElTag,
          { type: row.is_active === false ? 'danger' : 'success' },
          { default: () => (row.is_active === false ? '停用' : '启用') }
        )
    }
  ])

  const filteredTableData = computed(() => tableData.value)

  const handleReset = (): void => {
    Object.assign(formFilters, { ...initialSearchState })
    Object.assign(appliedFilters, { ...initialSearchState })
    pagination.page = 1
    getProductList()
  }

  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    pagination.page = 1
    getProductList()
  }

  const handleRefresh = (): void => {
    getProductList()
  }

  const handleSizeChange = (size: number): void => {
    pagination.pageSize = size
    pagination.page = 1
    getProductList()
  }

  const handleCurrentChange = (page: number): void => {
    pagination.page = page
    getProductList()
  }

  const handleCreate = (): void => {
    createDialogVisible.value = true
  }

  const handleCreateSubmit = async (): Promise<void> => {
    if (!createForm.name.trim()) {
      ElMessage.warning('请输入产品名称')
      return
    }
    if (!createForm.parent_category_id) {
      ElMessage.warning('请选择产品大类')
      return
    }
    if (!createForm.category_id) {
      ElMessage.warning('请选择规格')
      return
    }
    createLoading.value = true
    try {
      const payload = {
        is_sale: true,
        is_active: true,
        category_id: createForm.category_id,
        type_id: createForm.type_id,
        name: createForm.name.trim(),
        price: Number(createForm.price) || 0
      }
      const res = await createMatProductApi(payload)
      const data = (res as any).data || {}
      createDialogVisible.value = false
      // 重置表单
      createForm.parent_category_id = undefined
      createForm.category_id = undefined
      createForm.type_id = 1
      createForm.name = ''
      createForm.price = ''
      if (data.id) {
        router.push({ name: 'MatProductDetail', params: { id: data.id } })
      } else {
        ElMessage.success('创建成功')
        await getProductList()
      }
    } catch (error) {
      console.error('创建产品失败:', error)
      ElMessage.error('创建产品失败')
    } finally {
      createLoading.value = false
    }
  }

  const handleProductClick = (item: ProductItem): void => {
    if (item.id) {
      router.push({
        name: 'MatProductDetail',
        params: { id: item.id }
      })
    }
  }

  const getImageUrl = (imageUrl: string | undefined, logo: string | undefined): string => {
    const finalUrl = imageUrl || logo
    if (!finalUrl) return sdImage
    if (finalUrl.startsWith('http://') || finalUrl.startsWith('https://')) {
      return finalUrl
    }
    return finalUrl.startsWith('/') ? finalUrl : `/${finalUrl}`
  }

  const parseMlValue = (value?: string | number): number => {
    if (value === undefined || value === null) return Number.MAX_SAFE_INTEGER
    const text = String(value)
    const match = text.match(/(\d+(?:\.\d+)?)\s*(ml|l)/i)
    if (!match) return Number.MAX_SAFE_INTEGER
    const amount = Number(match[1])
    if (Number.isNaN(amount)) return Number.MAX_SAFE_INTEGER
    return match[2].toLowerCase() === 'l' ? amount * 1000 : amount
  }

  const normalizePropertyList = (res: any): CategoryNode[] => {
    const raw = res?.data
    const list = Array.isArray(raw) ? raw : raw?.list || raw?.data || raw?.records || []
    return list.filter((x: any) => x && x.id != null)
  }

  const currentFilterLabel = computed(() => {
    if (selectedParentId.value == null) return ''
    const root = rootCategories.value.find((r) => r.id === selectedParentId.value)
    const rootName = root?.name || ''
    if (selectedSpecId.value != null && selectedSpecId.value !== '') {
      const specs = specsByParentId[String(selectedParentId.value)] || []
      const spec = specs.find((s) => s.id === selectedSpecId.value)
      return spec ? `${rootName} · ${spec.name}` : `${rootName} · 规格`
    }
    return `${rootName} · 全部`
  })

  const loadRootCategories = async (): Promise<void> => {
    sidebarLoading.value = true
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'product_category',
        'q[parent_id_null]': true,
        per_page: 500
      })
      const list = normalizePropertyList(res)
      rootCategories.value = list.sort((a, b) =>
        (a.name || '').localeCompare(b.name || '', 'zh-CN')
      )
    } catch (error) {
      console.error('加载产品大类失败:', error)
      rootCategories.value = []
    } finally {
      sidebarLoading.value = false
    }
  }

  const fetchChildSpecs = async (parentId: number | string): Promise<void> => {
    const key = String(parentId)
    if (specsLoaded[key]) return
    specsLoadingId.value = parentId
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'product_category',
        'q[parent_id_eq]': parentId,
        per_page: 500
      })
      const list = normalizePropertyList(res)
      specsByParentId[key] = list.sort((a, b) => parseMlValue(a.name) - parseMlValue(b.name))
      specsLoaded[key] = true
    } catch (error) {
      console.error('加载规格失败:', error)
      specsByParentId[key] = []
      specsLoaded[key] = true
    } finally {
      specsLoadingId.value = null
    }
  }

  const onToggleRoot = async (root: CategoryNode): Promise<void> => {
    if (expandedRootId.value === root.id) {
      expandedRootId.value = null
      return
    }
    expandedRootId.value = root.id
    await fetchChildSpecs(root.id)
  }

  const onSelectAllSpecs = (parentId: number | string): void => {
    selectedParentId.value = parentId
    selectedSpecId.value = null
    pagination.page = 1
    getProductList()
  }

  const onSelectSpec = (parentId: number | string, specId: number | string): void => {
    selectedParentId.value = parentId
    selectedSpecId.value = specId
    pagination.page = 1
    getProductList()
  }

  /** 取消左侧分类筛选，恢复右侧展示全部产品 */
  const clearCategoryFilter = (): void => {
    selectedParentId.value = null
    selectedSpecId.value = null
    pagination.page = 1
    getProductList()
  }

  const getProductList = async (): Promise<void> => {
    loading.value = true
    try {
      const params: Record<string, any> = {
        page: pagination.page,
        per_page: pagination.pageSize
      }
      if (appliedFilters.name) params['q[name_cont]'] = appliedFilters.name
      if (appliedFilters.code) params['q[code_cont]'] = appliedFilters.code

      // 卡片模式：未选左侧分类时不带大类/规格参数，加载全部产品；选择后再按类别筛选
      if (viewMode.value === 'card') {
        if (selectedParentId.value != null && selectedParentId.value !== '') {
          if (selectedSpecId.value != null && selectedSpecId.value !== '') {
            params.spec_category_id = selectedSpecId.value
          } else {
            params.parent_category_id = selectedParentId.value
          }
        }
      }

      const res = await listMatProductApi(params)
      tableData.value = (res as any).data || []
      pagination.total = (res as any).total ?? tableData.value.length
    } catch (error) {
      console.error('获取产品列表失败:', error)
      tableData.value = []
      pagination.total = 0
      ElMessage.error('获取产品列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 显示批量添加弹窗
   */
  const showBatchAddDialog = () => {
    batchAddDialogVisible.value = true
  }

  /**
   * 显示批量编辑弹窗
   */
  const showBatchEditDialog = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要编辑的产品')
      return
    }
    batchEditDialogVisible.value = true
  }

  /**
   * 处理批量添加成功
   */
  const handleBatchAddSuccess = () => {
    pagination.page = 1
    getProductList()
  }

  /**
   * 处理批量编辑成功
   */
  const handleBatchEditSuccess = () => {
    getProductList()
    selectedRows.value = []
  }

  /**
   * 处理表格行选择变化
   */
  const handleSelectionChange = (selection: ProductItem[]) => {
    selectedRows.value = selection
  }

  /**
   * 处理批量删除
   */
  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的产品')
      return
    }

    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个产品吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        try {
          // 提取选中的ID
          const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
          if (selectedIds.length === 0) {
            ElMessage.warning('没有有效的产品ID')
            return
          }
          // 调用批量删除API
          await batchActionMatProductApi({
            actions: 'delete',
            ids: selectedIds
          })
          ElMessage.success('批量删除成功')
          getProductList()
          selectedRows.value = []
          // 清空表格选中状态
          if (proTable.value?.elTableRef) {
            proTable.value.elTableRef.clearSelection()
          }
        } catch (error) {
          console.error('批量删除失败:', error)
          ElMessage.error('批量删除失败，请重试')
        }
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  /**
   * 导出excel
   */
  const handleExport = () => {
    let _data: any = []

    // 通过 ref 获取 ElTable 实例
    const elTableInstance = proTable.value?.elTableRef

    if (elTableInstance) {
      // 使用 ElTable 实例的 getSelectionRows 方法获取选中的行
      const selectedRows = elTableInstance.getSelectionRows()
      if (selectedRows && selectedRows.length > 0) {
        _data = selectedRows
      } else if (filteredTableData.value && filteredTableData.value.length > 0) {
        // 如果没有选中的行，则导出所有数据
        _data = filteredTableData.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    } else {
      // 如果没有表格实例，使用当前数据
      if (filteredTableData.value && filteredTableData.value.length > 0) {
        _data = filteredTableData.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    }

    // 确保columns.value存在
    if (!columns.value || !columns.value.length) {
      ElMessage.warning('缺少表格列配置')
      return
    }

    try {
      // 使用表格标题或默认名称作为文件名
      const fileName = '产品数据'
      exportExcel(columns.value, _data, fileName)
      ElMessage.success('导出成功')
      // 清空选中数据
      if (elTableInstance) {
        elTableInstance.clearSelection()
      }
    } catch (error) {
      console.error('导出失败:', error)
      ElMessage.error('导出失败，请重试')
    }
  }

  watch(viewMode, () => {
    pagination.page = 1
    if (viewMode.value === 'list') {
      selectedParentId.value = null
      selectedSpecId.value = null
      expandedRootId.value = null
    }
    getProductList()
  })

  onMounted(async () => {
    await loadRootCategories()
    getProductList()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .product-page {
    @apply p-4;

    display: flex;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
  }

  .product-page-body {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
  }

  .card-view {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 0;
    margin-top: 4px;
    overflow: hidden;
  }

  .view-switch {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    padding: 2px;
    background: var(--el-fill-color-light);
    border-radius: 6px;
  }

  .category-layout {
    display: flex;
    flex: 1;
    gap: 20px;
    align-items: stretch;
    min-height: 0;
    overflow: hidden;
  }

  .category-sidebar {
    flex-shrink: 0;
    align-self: stretch;
    width: 288px;
    max-height: 100%;
    overflow: hidden auto;
    background: linear-gradient(180deg, #fff 0%, #fafbfc 100%);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 12px;
    box-shadow: 0 1px 2px rgb(0 0 0 / 4%);
  }

  .sidebar-title {
    padding: 14px 16px 10px;
    font-size: 13px;
    font-weight: 600;
    color: var(--el-text-color-secondary);
    letter-spacing: 0.02em;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .sidebar-empty {
    padding: 24px 16px;
    font-size: 13px;
    color: var(--el-text-color-placeholder);
    text-align: center;
  }

  .category-section + .category-section {
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .category-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 14px;
    cursor: pointer;
    transition: background 0.15s;
  }

  .category-header:hover {
    background: rgb(64 158 255 / 6%);
  }

  .category-header.active {
    background: rgb(64 158 255 / 8%);
  }

  .category-name {
    flex: 1;
    min-width: 0;
    padding-right: 8px;
    font-size: 14px;
    font-weight: 600;
    line-height: 1.35;
    color: var(--el-color-primary);
  }

  .category-arrow {
    flex-shrink: 0;
    font-size: 18px;
    color: var(--el-text-color-secondary);
    transition: transform 0.2s;
  }

  .category-arrow.expanded {
    transform: rotate(180deg);
  }

  .capacity-panel {
    padding-bottom: 4px;
  }

  .specs-loading {
    padding: 8px 14px 14px;
    font-size: 12px;
    color: var(--el-text-color-placeholder);
  }

  .capacity-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
    padding: 0 12px 12px;
  }

  .capacity-item {
    min-height: 36px;
    padding: 6px 8px;
    font-size: 12px;
    line-height: 1.25;
    color: var(--el-text-color-regular);
    cursor: pointer;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: all 0.2s;
  }

  .capacity-item:hover {
    color: var(--el-color-primary);
    border-color: var(--el-color-primary-light-5);
    box-shadow: 0 2px 8px rgb(64 158 255 / 12%);
  }

  .capacity-item.active {
    font-weight: 600;
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary-light-5);
  }

  .category-products {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
    padding: 4px 0 0;
    overflow: hidden;
  }

  .product-cards-scroll {
    position: relative;
    flex: 1;
    min-height: 0;
    overflow: auto;
  }

  .products-toolbar {
    margin-bottom: 14px;
  }

  .toolbar-info {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
  }

  .toolbar-label {
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .toolbar-count {
    font-size: 13px;
    color: var(--el-text-color-placeholder);
  }

  .toolbar-hint {
    font-size: 13px;
    color: var(--el-text-color-placeholder);
  }

  .toolbar-clear {
    margin-left: 4px;
    font-size: 13px;
  }

  .product-card-grid {
    position: relative;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 18px;
    min-height: 200px;
  }

  .products-empty {
    display: flex;
    flex-direction: column;
    grid-column: 1 / -1;
    align-items: center;
    justify-content: center;
    padding: 48px 24px;
    color: var(--el-text-color-placeholder);
    text-align: center;
    background: var(--el-fill-color-blank);
    border: 1px dashed var(--el-border-color);
    border-radius: 12px;
  }

  .products-empty .empty-icon {
    margin-bottom: 12px;
    font-size: 40px;
    opacity: 0.45;
  }

  .products-empty p {
    margin: 0;
    font-size: 14px;
  }

  .product-card {
    overflow: hidden;
    cursor: pointer;
    border-radius: 12px;
    transition:
      transform 0.2s,
      box-shadow 0.2s;
  }

  .product-card:hover {
    box-shadow: 0 8px 24px rgb(0 0 0 / 8%);
    transform: translateY(-2px);
  }

  .product-card-inner {
    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .card-media {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 176px;
    background: linear-gradient(145deg, #f5f7fa 0%, #eef1f6 100%);
    border-radius: 0;
  }

  .card-detail-btn {
    position: absolute;
    right: 10px;
    bottom: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    padding: 0;
    font-size: 22px;
    color: #fff;
    cursor: pointer;
    background: var(--el-color-primary);
    border: none;
    border-radius: 50%;
    box-shadow: 0 4px 12px rgb(64 158 255 / 35%);
    transition: transform 0.2s;
  }

  .card-detail-btn:hover {
    transform: scale(1.06);
  }

  .card-image {
    width: 100%;
    height: 100%;
  }

  .card-content {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding: 14px 14px 16px;
  }

  .card-code {
    font-size: 17px;
    font-weight: 700;
    color: var(--el-text-color-primary);
    letter-spacing: 0.02em;
  }

  .card-name {
    display: -webkit-box;
    min-height: 2.6em;
    overflow: hidden;
    font-size: 13px;
    line-height: 1.35;
    color: var(--el-text-color-regular);
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;
  }

  .card-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }

  .card-specs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 6px 12px;
    padding-top: 4px;
    margin: 0;
    font-size: 12px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .spec-row {
    display: flex;
    flex-direction: column;
    gap: 2px;
    min-width: 0;
  }

  .spec-row-full {
    grid-column: 1 / -1;
  }

  .spec-row dt {
    margin: 0;
    font-size: 11px;
    font-weight: 500;
    color: var(--el-text-color-placeholder);
  }

  .spec-row dd {
    margin: 0;
    overflow: hidden;
    font-weight: 500;
    color: var(--el-text-color-regular);
    text-overflow: ellipsis;
    white-space: nowrap;
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

  .art-table-card {
    margin-top: 4px;
  }

  .pagination-wrapper {
    display: flex;
    flex-shrink: 0;
    justify-content: flex-end;
    padding: 12px 4px 4px;
  }

  .pagination-wrapper--card {
    width: 100%;
    padding: 14px 0 6px;
    margin-top: auto;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  @media (width <= 1200px) {
    .category-layout {
      flex-direction: column;
    }

    .category-sidebar {
      width: 100%;
    }
  }
</style>
