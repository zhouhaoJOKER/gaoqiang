<!-- 物品列表页面 -->
<template>
  <div class="item-page art-full-height">
    <div class="flex items-center justify-between mb-3">
      <div class="flex items-center gap-3">
        <span class="text-base font-medium text-g-900">物品</span>
      </div>
      <div class="flex items-center gap-2">
        <ElDropdown trigger="click">
          <ElButton type="default" v-ripple>
            <ArtSvgIcon icon="ri:more-2-line" />
            更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
          </ElButton>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem @click="handleExport">
                <ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                导出
              </ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
      </div>
    </div>

    <ArtSearchBar
      v-model="formFilters"
      :items="formItems"
      :showExpand="false"
      class="mb-1"
      @reset="handleReset"
      @search="handleSearch"
    />

    <ElCard class="art-table-card" shadow="never">
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

    <!-- 编辑弹窗 -->
    <ItemEditDialog
      v-model="editDialogVisible"
      :item-data="currentItemData"
      @success="handleEditSuccess"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref, reactive, computed, onMounted } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import {
    ElButton,
    ElCard,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon,
    ElMessage,
    ElPagination,
    ElTag,
    ElTooltip
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { listMatItemApi } from '@/api/mat/item'
  import { exportExcel } from '@/utils/tool/toExcel'
  import ItemEditDialog from './modules/item-edit-dialog.vue'

  defineOptions({ name: 'MatItems' })

  interface ItemItem {
    id?: string | number
    name?: string
    logo?: string
    code?: string
    py?: string
    pinyin?: string
    barcode?: string
    type_id?: string | number
    type_name?: string
    category_id?: string | number
    category_name?: string
    price?: number | string
    cost_price?: number | string
    market_price?: number | string
    description?: string
    uom_id?: string | number
    uom_po_id?: string | number
    sale_tax_id?: string | number
    purchase_tax_id?: string | number
    is_sale?: boolean
    is_purchase?: boolean
    is_manufacture?: boolean
    is_stock?: boolean
    is_active?: boolean
    product_id?: string | number
    product_name?: string
    value_id?: string | number
    sku?: string
    weight?: number | string
    volume?: number | string
    qty_onhand?: number
    qty_available?: number
    qty_incoming?: number
    qty_outgoing?: number
    [key: string]: any
  }

  const loading = ref(false)
  const editDialogVisible = ref(false)
  const currentItemData = ref<ItemItem | undefined>(undefined)
  const proTable = ref()
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })

  const initialSearchState = {
    name: '',
    code: '',
    sku: '',
    barcode: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '名称',
      key: 'name',
      type: 'input',
      props: { clearable: true, placeholder: '请输入物品名称' }
    },
    {
      label: '编码',
      key: 'code',
      type: 'input',
      props: { clearable: true, placeholder: '请输入物品编码' }
    },
    {
      label: 'SKU',
      key: 'sku',
      type: 'input',
      props: { clearable: true, placeholder: '请输入SKU' }
    },
    {
      label: '条形码',
      key: 'barcode',
      type: 'input',
      props: { clearable: true, placeholder: '请输入条形码' }
    }
  ])

  const tableData = ref<ItemItem[]>([])

  const { columnChecks, columns } = useTableColumns(() => [
    {
      prop: 'name',
      label: '名称',
      minWidth: 200,
      formatter: (row: ItemItem) => {
        return h('div', { class: 'flex items-center gap-2' }, [
          h(
            'span',
            {
              class: 'cursor-pointer hover:text-primary-500 transition-colors',
              onClick: () => handleEdit(row)
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
      prop: 'sku',
      label: 'SKU',
      minWidth: 120,
      formatter: (row: ItemItem) => row.sku || '-'
    },
    {
      prop: 'barcode',
      label: '条形码',
      minWidth: 120,
      formatter: (row: ItemItem) => row.barcode || '-'
    },
    {
      prop: 'product_name',
      label: '产品',
      minWidth: 140,
      formatter: (row: ItemItem) => row.product_name || '-'
    },
    {
      prop: 'category_name',
      label: '分类',
      minWidth: 140,
      formatter: (row: ItemItem) => row.category_name || '未设置'
    },
    {
      prop: 'type_name',
      label: '类型',
      minWidth: 120,
      formatter: (row: ItemItem) => row.type_name || row.type_id || '未设置'
    },
    {
      prop: 'price',
      label: '售价',
      minWidth: 120,
      formatter: (row: ItemItem) => formatCurrency(row.price)
    },
    {
      prop: 'cost_price',
      label: '成本价',
      minWidth: 120,
      formatter: (row: ItemItem) => formatCurrency(row.cost_price)
    },
    {
      prop: 'market_price',
      label: '市场价',
      minWidth: 120,
      formatter: (row: ItemItem) => formatCurrency(row.market_price)
    },
    {
      prop: 'qty_onhand',
      label: '在手数量',
      minWidth: 100,
      formatter: (row: ItemItem) => row.qty_onhand ?? 0
    },
    {
      prop: 'qty_available',
      label: '可用数量',
      minWidth: 100,
      formatter: (row: ItemItem) => row.qty_available ?? 0
    },
    {
      prop: 'is_active',
      label: '状态',
      minWidth: 100,
      formatter: (row: ItemItem) =>
        h(
          ElTag,
          { type: row.is_active === false ? 'danger' : 'success' },
          { default: () => (row.is_active === false ? '停用' : '启用') }
        )
    },
    {
      prop: 'operation',
      label: '操作',
      width: 100,
      fixed: 'right',
      formatter: (row: ItemItem) =>
        h(
          ElButton,
          {
            type: 'primary',
            size: 'small',
            onClick: () => handleEdit(row)
          },
          { default: () => '编辑' }
        )
    }
  ])

  const filteredTableData = computed(() => tableData.value)

  const handleReset = (): void => {
    Object.assign(formFilters, { ...initialSearchState })
    Object.assign(appliedFilters, { ...initialSearchState })
    pagination.page = 1
    getItemList()
  }

  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    pagination.page = 1
    getItemList()
  }

  const handleRefresh = (): void => {
    getItemList()
  }

  const handleSizeChange = (size: number): void => {
    pagination.pageSize = size
    pagination.page = 1
    getItemList()
  }

  const handleCurrentChange = (page: number): void => {
    pagination.page = page
    getItemList()
  }

  const handleEdit = (item: ItemItem): void => {
    currentItemData.value = item
    editDialogVisible.value = true
  }

  const handleEditSuccess = (): void => {
    getItemList()
  }

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }

  const getItemList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listMatItemApi({
        ...appliedFilters,
        page: pagination.page,
        per_page: pagination.pageSize
      })
      tableData.value = (res as any).data || []
      pagination.total = (res as any).total || tableData.value.length
    } catch (error) {
      console.error('获取物品列表失败:', error)
      tableData.value = []
      pagination.total = 0
      ElMessage.error('获取物品列表失败')
    } finally {
      loading.value = false
    }
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
      const fileName = '物品数据'
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

  onMounted(() => {
    getItemList()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .item-page {
    @apply p-4;

    display: flex;
    flex-direction: column;
  }

  .art-table-card {
    margin-top: 4px;
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 12px 4px 4px;
  }
</style>
