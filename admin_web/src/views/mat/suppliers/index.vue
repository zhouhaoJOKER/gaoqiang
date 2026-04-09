<!-- 供应商列表页面 -->
<template>
  <div class="art-full-height">
    <SupplierSearch
      v-show="showSearchBar"
      v-model="searchForm"
      @search="handleSearch"
      @reset="resetSearchParams"
    />

    <ElCard
      class="art-table-card"
      shadow="never"
      :style="{ 'margin-top': showSearchBar ? '12px' : '0' }"
    >
      <ArtTableHeader
        v-model:columns="columnChecks"
        v-model:showSearchBar="showSearchBar"
        :loading="loading"
        @refresh="refreshData"
      >
        <template #left>
          <ElSpace wrap>
            <ElButton type="primary" @click="handleCreate" v-ripple>
              <ArtSvgIcon icon="ri:add-line" />
              新建供应商
            </ElButton>
            <ElDropdown
              trigger="click"
              v-if="
                hasAuth('batchAdd') ||
                hasAuth('batchEdit') ||
                hasAuth('batchDelete') ||
                hasAuth('import') ||
                hasAuth('export')
              "
            >
              <ElButton type="default" v-ripple>
                <ArtSvgIcon icon="ri:more-2-line" />
                更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem v-if="hasAuth('batchAdd')" @click="showBatchAddDialog">
                    <ArtSvgIcon class="el-icon--left" icon="ri:add-circle-line" />
                    批量添加
                  </ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('batchEdit')" @click="showBatchEditDialog">
                    <ArtSvgIcon class="el-icon--left" icon="ri:edit-box-line" />
                    批量编辑
                  </ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('batchDelete')" @click="handleBatchDelete">
                    <ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                    批量删除
                  </ElDropdownItem>
                  <ElDropdownItem
                    v-if="hasAuth('import') || hasAuth('export')"
                    divided
                  ></ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('import')" @click="showImportDialog">
                    <ArtSvgIcon class="el-icon--left" icon="ri:upload-line" /> 导入
                  </ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('export')" @click="handleExport">
                    <ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                    导出
                  </ElDropdownItem>
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </ElSpace>
        </template>
      </ArtTableHeader>

      <!-- 表格 -->
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as SupplierItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <!-- 创建/编辑供应商对话框 -->
    <SupplierDialog
      v-model="dialogVisible"
      :supplier="currentSupplier"
      :readonly="isViewMode"
      @created="handleSupplierCreated"
      @updated="handleSupplierUpdated"
    />

    <!-- 批量添加弹窗 -->
    <SupplierBatchAddDialog v-model="batchAddDialogVisible" @success="handleBatchAddSuccess" />

    <!-- 批量编辑弹窗 -->
    <SupplierBatchEditDialog
      v-model="batchEditDialogVisible"
      :selectedRows="selectedRows"
      @success="handleBatchEditSuccess"
    />

    <!-- 导入弹窗 -->
    <SupplierImportDialog v-model="importDialogVisible" @success="handleImportSuccess" />

    <!-- 公司创建对话框 -->
    <CompanyDialog v-model:visible="companyDialogVisible" @submit="handleCompanyCreated" />

    <!-- 产品创建对话框（通过路由跳转） -->
    <ElDialog v-model="productDialogVisible" title="提示" width="400px">
      <p>产品创建功能请在产品管理页面操作</p>
      <template #footer>
        <ElButton @click="productDialogVisible = false">确定</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import { useAuth } from '@/hooks/core/useAuth'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import SupplierSearch from './modules/supplier-search.vue'
  import SupplierDialog from './modules/supplier-dialog.vue'
  import CompanyDialog from '@/views/system/company/modules/company-dialog.vue'
  import {
    ElButton,
    ElCard,
    ElMessage,
    ElMessageBox,
    ElSpace,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon,
    ElDialog
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import {
    listMatSupplierApi,
    deleteMatSupplierApi,
    batchActionMatSupplierApi
  } from '@/api/mat/supplier'
  import { exportExcel } from '@/utils/tool/toExcel'
  import SupplierBatchAddDialog from './modules/supplier-batch-add-dialog.vue'
  import SupplierBatchEditDialog from './modules/supplier-batch-edit-dialog.vue'
  import SupplierImportDialog from './modules/supplier-import-dialog.vue'

  defineOptions({ name: 'MatSupplier' })

  interface SupplierItem {
    id?: string | number
    name?: string
    code?: string
    py?: string
    pinyin?: string
    company_id?: string | number
    company_name?: string
    product_id?: string | number
    product_name?: string
    min_qty?: number | string
    price?: number | string
    currency_id?: string | number
    currency_name?: string
    delay?: number
    is_main?: boolean
    sort?: number | string
    [key: string]: any
  }

  // 搜索表单
  const searchForm = ref({
    name_cont: undefined,
    code_cont: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)

  const { hasAuth } = useAuth()

  const dialogVisible = ref(false)
  const currentSupplier = ref<SupplierItem | undefined>(undefined)
  const isViewMode = ref(false)

  // 批量操作相关
  const batchAddDialogVisible = ref(false)
  const batchEditDialogVisible = ref(false)
  const importDialogVisible = ref(false)
  const selectedRows = ref<SupplierItem[]>([])
  const companyDialogVisible = ref(false)
  const productDialogVisible = ref(false)

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    getData,
    searchParams,
    refreshCreate,
    refreshUpdate,
    refreshRemove,
    resetSearchParams,
    handleSizeChange,
    handleCurrentChange,
    refreshData
  } = useTable({
    core: {
      apiFn: listMatSupplierApi,
      apiParams: {
        page: 1,
        per_page: 20
      },
      columnsFactory: () => [
        { type: 'selection' }, // 勾选列
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '供应商名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(supplierRow)
              },
              supplierRow.name || ''
            )
          }
        },
        {
          prop: 'code',
          label: '供应商编码',
          minWidth: 120,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.code || '-'
          }
        },
        {
          prop: 'company_name',
          label: '公司',
          minWidth: 120,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.company_name || '未设置'
          }
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.product_name || '-'
          }
        },
        {
          prop: 'min_qty',
          label: '最小数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.min_qty || 0
          }
        },
        {
          prop: 'price',
          label: '价格',
          minWidth: 100,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return formatCurrency(supplierRow.price)
          }
        },
        {
          prop: 'currency_name',
          label: '货币',
          minWidth: 80,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.currency_name || '-'
          }
        },
        {
          prop: 'delay',
          label: '延迟天数',
          minWidth: 100,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.delay || 0
          }
        },
        {
          prop: 'is_main',
          label: '主供应商',
          minWidth: 100,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return h(
              'span',
              { class: supplierRow.is_main ? 'text-success' : 'text-g-400' },
              supplierRow.is_main ? '是' : '否'
            )
          }
        },
        {
          prop: 'sort',
          label: '排序',
          minWidth: 80,
          formatter: (row: unknown) => {
            const supplierRow = row as SupplierItem
            return supplierRow.sort || 0
          }
        },
        {
          prop: 'operation',
          label: '操作',
          width: 86,
          fixed: 'right',
          formatter: (row: unknown) =>
            h('div', { style: 'display: flex' }, [
              h(ArtButtonTable, {
                type: 'view',
                onClick: () => buttonMoreClick({ key: 'view' }, row as SupplierItem)
              }),
              h(ArtButtonMore, {
                list: [
                  {
                    key: 'edit',
                    label: '编辑供应商',
                    icon: 'ri:edit-2-line'
                  },
                  {
                    key: 'delete',
                    label: '删除供应商',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as SupplierItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: SupplierItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteSupplier(row)
        break
    }
  }

  const handleCreate = (): void => {
    currentSupplier.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleCompanyCreated = async (companyData: any): Promise<void> => {
    try {
      const { createCompanyApi } = await import('@/api/company')
      await createCompanyApi(companyData)
      ElMessage.success('公司创建成功，请刷新搜索栏')
      companyDialogVisible.value = false
    } catch (error: any) {
      console.error('创建公司失败:', error)
      ElMessage.error(error?.message || '创建公司失败')
    }
  }

  const handleView = (row?: SupplierItem): void => {
    currentSupplier.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: SupplierItem): void => {
    currentSupplier.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteSupplier = (row: SupplierItem) => {
    ElMessageBox.confirm(
      `确定删除供应商"${row.name || '未命名'}"吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(() => {
        deleteMatSupplierApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleSupplierCreated = (supplier: any): void => {
    if (supplier && supplier.id) {
      refreshCreate()
    }
  }

  const handleSupplierUpdated = (supplier: any): void => {
    if (supplier && supplier.id) {
      refreshUpdate()
    }
  }

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }

  /**
   * 搜索处理
   * @param params 搜索参数
   */
  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
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
      ElMessage.warning('请先选择要编辑的供应商')
      return
    }
    batchEditDialogVisible.value = true
  }

  /**
   * 显示导入弹窗
   */
  const showImportDialog = () => {
    importDialogVisible.value = true
  }

  /**
   * 处理批量添加成功
   */
  const handleBatchAddSuccess = () => {
    refreshCreate()
  }

  /**
   * 处理批量编辑成功
   */
  const handleBatchEditSuccess = () => {
    refreshUpdate()
    selectedRows.value = []
  }

  /**
   * 处理导入成功
   */
  const handleImportSuccess = () => {
    refreshCreate()
  }

  /**
   * 处理表格行选择变化
   */
  const handleSelectionChange = (selection: SupplierItem[]) => {
    selectedRows.value = selection
  }

  /**
   * 处理批量删除
   */
  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的供应商')
      return
    }

    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个供应商吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        // 提取选中的ID
        const selectedIds = selectedRows.value.map((row) => row.id)
        // 调用批量删除API
        await batchActionMatSupplierApi({
          actions: 'delete',
          ids: selectedIds
        })
        ElMessage.success('批量删除成功')
        refreshRemove()
        selectedRows.value = []
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
      } else if (data.value && data.value.length > 0) {
        // 如果没有选中的行，则导出所有数据
        _data = data.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    } else {
      ElMessage.warning('表格实例未获取到')
      return
    }

    // 确保columns.value存在
    if (!columns.value || !columns.value.length) {
      ElMessage.warning('缺少表格列配置')
      return
    }

    try {
      // 使用表格标题或默认名称作为文件名
      const fileName = '供应商数据'
      exportExcel(columns.value, _data, fileName)
      ElMessage.success('导出成功')
      // 清空选中数据
      elTableInstance.clearSelection()
    } catch (error) {
      console.error('导出失败:', error)
      ElMessage.error('导出失败，请重试')
    }
  }
</script>
