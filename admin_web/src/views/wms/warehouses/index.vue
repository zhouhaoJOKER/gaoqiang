<!-- 仓库列表页面 -->
<template>
  <div class="art-full-height">
    <WarehouseSearch
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
              新建仓库
            </ElButton>
            <ElDropdown trigger="click">
              <ElButton type="default" v-ripple>
                <ArtSvgIcon icon="ri:more-2-line" />
                更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
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
          </ElSpace>
        </template>
      </ArtTableHeader>

      <!-- 表格 -->
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as WarehouseItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <!-- 创建/编辑仓库对话框 -->
    <WarehouseDialog
      v-model="dialogVisible"
      :warehouse="currentWarehouse"
      :readonly="isViewMode"
      @created="handleWarehouseCreated"
      @updated="handleWarehouseUpdated"
    />

    <!-- 公司创建对话框 -->
    <CompanyDialog v-model:visible="companyDialogVisible" @submit="handleCompanyCreated" />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import WarehouseSearch from './modules/warehouse-search.vue'
  import WarehouseDialog from './modules/warehouse-dialog.vue'
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
    ElIcon
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import {
    listWmsWarehouseApi,
    deleteWmsWarehouseApi,
    batchActionWmsWarehouseApi
  } from '@/api/wms/warehouse'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'WmsWarehouse' })

  interface WarehouseItem {
    id?: string | number
    name?: string
    abbr?: string
    code?: string
    type_id?: string | number
    type_name?: string
    is_active?: boolean
    sort?: number | string
    company_id?: string | number
    company_name?: string
    description?: string
    py?: string
    pinyin?: string
    [key: string]: any
  }

  // 搜索表单
  const searchForm = ref({
    name_cont: undefined,
    code_cont: undefined,
    company_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)

  const dialogVisible = ref(false)
  const currentWarehouse = ref<WarehouseItem | undefined>(undefined)
  const isViewMode = ref(false)
  const companyDialogVisible = ref(false)

  // 批量操作相关
  const selectedRows = ref<WarehouseItem[]>([])

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
      apiFn: listWmsWarehouseApi,
      apiParams: {
        page: 1,
        per_page: 20
      },
      columnsFactory: () => [
        { type: 'selection' }, // 勾选列
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '仓库名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(warehouseRow)
              },
              warehouseRow.name || ''
            )
          }
        },
        {
          prop: 'code',
          label: '仓库编码',
          minWidth: 120,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return warehouseRow.code || '-'
          }
        },
        {
          prop: 'abbr',
          label: '简称',
          minWidth: 100,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return warehouseRow.abbr || '-'
          }
        },
        {
          prop: 'company_name',
          label: '公司',
          minWidth: 120,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return warehouseRow.company_name || '未设置'
          }
        },
        {
          prop: 'type_name',
          label: '类型',
          minWidth: 100,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return warehouseRow.type_name || '-'
          }
        },
        {
          prop: 'is_active',
          label: '状态',
          minWidth: 80,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return h(
              ElTag,
              { type: warehouseRow.is_active === false ? 'danger' : 'success' },
              { default: () => (warehouseRow.is_active === false ? '停用' : '启用') }
            )
          }
        },
        {
          prop: 'sort',
          label: '排序',
          minWidth: 80,
          formatter: (row: unknown) => {
            const warehouseRow = row as WarehouseItem
            return warehouseRow.sort || 0
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as WarehouseItem)
              }),
              h(ArtButtonMore, {
                list: [
                  {
                    key: 'edit',
                    label: '编辑仓库',
                    icon: 'ri:edit-2-line'
                  },
                  {
                    key: 'delete',
                    label: '删除仓库',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as WarehouseItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: WarehouseItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteWarehouse(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = (): void => {
    currentWarehouse.value = undefined
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

  const handleView = (row?: WarehouseItem): void => {
    currentWarehouse.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: WarehouseItem): void => {
    currentWarehouse.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteWarehouse = (row: WarehouseItem) => {
    ElMessageBox.confirm(`确定删除仓库"${row.name || '未命名'}"吗？此操作不可恢复！`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteWmsWarehouseApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleWarehouseCreated = (warehouse: any): void => {
    if (warehouse && warehouse.id) {
      refreshCreate()
    }
  }

  const handleWarehouseUpdated = (warehouse: any): void => {
    if (warehouse && warehouse.id) {
      refreshUpdate()
    }
  }

  /**
   * 处理表格行选择变化
   */
  const handleSelectionChange = (selection: WarehouseItem[]) => {
    selectedRows.value = selection
  }

  /**
   * 处理批量删除
   */
  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的仓库')
      return
    }

    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个仓库吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        try {
          const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
          if (selectedIds.length === 0) {
            ElMessage.warning('没有有效的仓库ID')
            return
          }
          await batchActionWmsWarehouseApi({
            actions: 'delete',
            ids: selectedIds
          })
          ElMessage.success('批量删除成功')
          refreshData()
          selectedRows.value = []
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
    const elTableInstance = proTable.value?.elTableRef

    if (elTableInstance) {
      const selectedRows = elTableInstance.getSelectionRows()
      if (selectedRows && selectedRows.length > 0) {
        _data = selectedRows
      } else if (data.value && data.value.length > 0) {
        _data = data.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    } else {
      if (data.value && data.value.length > 0) {
        _data = data.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    }

    if (!columns.value || !columns.value.length) {
      ElMessage.warning('缺少表格列配置')
      return
    }

    try {
      const fileName = '仓库数据'
      exportExcel(columns.value, _data, fileName)
      ElMessage.success('导出成功')
      if (elTableInstance) {
        elTableInstance.clearSelection()
      }
    } catch (error) {
      console.error('导出失败:', error)
      ElMessage.error('导出失败，请重试')
    }
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
