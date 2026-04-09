<!-- 批次序列号列表页面 -->
<template>
  <div class="lot-page art-full-height">
    <div class="flex items-center justify-between mb-3">
      <div class="flex items-center gap-3">
        <span class="text-base font-medium text-g-900">批次序列号</span>
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
    <LotEditDialog
      v-model="editDialogVisible"
      :lot-data="currentLotData"
      @success="handleEditSuccess"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref, reactive, computed, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
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
    ElPagination
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { listInvLotApi } from '@/api/inv/lot'
  import { exportExcel } from '@/utils/tool/toExcel'
  import LotEditDialog from './modules/lot-edit-dialog.vue'

  defineOptions({ name: 'InvLots' })

  const router = useRouter()

  interface LotItem {
    id?: string | number
    code?: string
    ref?: string
    item_id?: string | number
    item_name?: string
    product_id?: string | number
    product_name?: string
    company_id?: string | number
    company_name?: string
    qty?: number | string
    unit_cost?: number | string
    expiration_date?: string
    alert_date?: string
    removal_date?: string
    order_type?: string
    order_id?: string | number
    order_line_id?: string | number
    user_id?: string | number
    user_name?: string
    description?: string
    [key: string]: any
  }

  const loading = ref(false)
  const editDialogVisible = ref(false)
  const currentLotData = ref<LotItem | undefined>(undefined)
  const proTable = ref()
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })

  const initialSearchState = {
    code: '',
    ref: '',
    item_id: '',
    product_id: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '批次号',
      key: 'code',
      type: 'input',
      props: { clearable: true, placeholder: '请输入批次号' }
    },
    {
      label: '参考号',
      key: 'ref',
      type: 'input',
      props: { clearable: true, placeholder: '请输入参考号' }
    },
    {
      label: '物品ID',
      key: 'item_id',
      type: 'input',
      props: { clearable: true, placeholder: '请输入物品ID' }
    },
    {
      label: '产品ID',
      key: 'product_id',
      type: 'input',
      props: { clearable: true, placeholder: '请输入产品ID' }
    }
  ])

  const tableData = ref<LotItem[]>([])

  const { columnChecks, columns } = useTableColumns(() => [
    {
      prop: 'code',
      label: '批次号',
      minWidth: 150,
      formatter: (row: LotItem) => {
        return h('div', { class: 'flex items-center gap-2' }, [
          h(
            'span',
            {
              class: 'cursor-pointer hover:text-primary-500 transition-colors',
              onClick: () => handleView(row)
            },
            row.code || '-'
          )
        ])
      }
    },
    {
      prop: 'ref',
      label: '参考号',
      minWidth: 120,
      formatter: (row: LotItem) => row.ref || '-'
    },
    {
      prop: 'item_name',
      label: '物品',
      minWidth: 150,
      formatter: (row: LotItem) => row.item_name || '-'
    },
    {
      prop: 'product_name',
      label: '产品',
      minWidth: 150,
      formatter: (row: LotItem) => row.product_name || '-'
    },
    {
      prop: 'company_name',
      label: '公司',
      minWidth: 120,
      formatter: (row: LotItem) => row.company_name || '-'
    },
    {
      prop: 'qty',
      label: '数量',
      minWidth: 100,
      formatter: (row: LotItem) => {
        const num = Number(row.qty)
        return Number.isNaN(num) ? '0' : num.toFixed(2)
      }
    },
    {
      prop: 'unit_cost',
      label: '单位成本',
      minWidth: 120,
      formatter: (row: LotItem) => formatCurrency(row.unit_cost)
    },
    {
      prop: 'expiration_date',
      label: '过期日期',
      minWidth: 120,
      formatter: (row: LotItem) => formatDate(row.expiration_date)
    },
    {
      prop: 'alert_date',
      label: '提醒日期',
      minWidth: 120,
      formatter: (row: LotItem) => formatDate(row.alert_date)
    },
    {
      prop: 'removal_date',
      label: '移除日期',
      minWidth: 120,
      formatter: (row: LotItem) => formatDate(row.removal_date)
    },
    {
      prop: 'order_type',
      label: '订单类型',
      minWidth: 100,
      formatter: (row: LotItem) => row.order_type || '-'
    },
    {
      prop: 'user_name',
      label: '用户',
      minWidth: 100,
      formatter: (row: LotItem) => row.user_name || '-'
    },
    {
      prop: 'operation',
      label: '操作',
      width: 100,
      fixed: 'right',
      formatter: (row: LotItem) =>
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
    getLotList()
  }

  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    pagination.page = 1
    getLotList()
  }

  const handleRefresh = (): void => {
    getLotList()
  }

  const handleSizeChange = (size: number): void => {
    pagination.pageSize = size
    pagination.page = 1
    getLotList()
  }

  const handleCurrentChange = (page: number): void => {
    pagination.page = page
    getLotList()
  }

  const handleView = (item: LotItem): void => {
    if (item.id) {
      router.push({
        name: 'InvLotDetail',
        params: { id: item.id }
      })
    }
  }

  const handleEdit = (item: LotItem): void => {
    currentLotData.value = item
    editDialogVisible.value = true
  }

  const handleEditSuccess = (): void => {
    getLotList()
  }

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }

  const formatDate = (value: string | undefined): string => {
    if (!value) return '-'
    try {
      const date = new Date(value)
      return date.toLocaleDateString('zh-CN')
    } catch {
      return value
    }
  }

  const getLotList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listInvLotApi({
        ...appliedFilters,
        page: pagination.page,
        per_page: pagination.pageSize
      })
      tableData.value = (res as any).data || []
      pagination.total = (res as any).total || tableData.value.length
    } catch (error) {
      console.error('获取批次序列号列表失败:', error)
      tableData.value = []
      pagination.total = 0
      ElMessage.error('获取批次序列号列表失败')
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
      const fileName = '批次序列号数据'
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
    getLotList()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .lot-page {
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
