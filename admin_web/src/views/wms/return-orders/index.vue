<!-- 退货单列表页面 -->
<template>
  <div class="art-full-height">
    <ReturnOrderSearch
      v-show="showSearchBar"
      v-model="searchForm"
      @search="handleSearch"
      @reset="resetSearchParams"
      @add="handleCreate"
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
              新建退货单
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

      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as ReturnOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <ReturnOrderDialog
      v-model="dialogVisible"
      :returnOrder="currentReturnOrder"
      :readonly="isViewMode"
      @created="handleReturnOrderCreated"
      @updated="handleReturnOrderUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import ReturnOrderSearch from './modules/return-order-search.vue'
  import ReturnOrderDialog from './modules/return-order-dialog.vue'
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
    ElTag
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import {
    listWmsReturnOrderApi,
    deleteWmsReturnOrderApi,
    batchActionWmsReturnOrderApi
  } from '@/api/wms/return-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'WmsReturnOrder' })

  interface ReturnOrderItem {
    id?: string | number
    code?: string
    return_category?: string
    status?: string
    original_order_id?: string | number
    warehouse_id?: string | number
    warehouse_name?: string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    status_eq: undefined,
    return_category_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentReturnOrder = ref<ReturnOrderItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<ReturnOrderItem[]>([])

  type TagType = 'success' | 'danger' | 'warning' | 'info' | 'primary'
  const getStatusTag = (status?: string): { type: TagType; label: string } => {
    const statusMap: Record<string, { type: TagType; label: string }> = {
      pending: { type: 'warning', label: '待处理' },
      processing: { type: 'primary', label: '处理中' },
      completed: { type: 'success', label: '已完成' },
      cancelled: { type: 'info', label: '已取消' }
    }
    return statusMap[status || ''] || { type: 'info', label: status || '-' }
  }

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
      apiFn: listWmsReturnOrderApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '单据编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const orderRow = row as ReturnOrderItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(orderRow)
              },
              orderRow.code || '-'
            )
          }
        },
        {
          prop: 'return_category',
          label: '退货类别',
          minWidth: 120,
          formatter: (row: unknown) => {
            const orderRow = row as ReturnOrderItem
            const categoryMap: Record<string, string> = {
              production: '生产退货',
              sales: '销售退货',
              purchase: '采购退货'
            }
            return categoryMap[orderRow.return_category || ''] || orderRow.return_category || '-'
          }
        },
        {
          prop: 'status',
          label: '状态',
          minWidth: 100,
          formatter: (row: unknown) => {
            const orderRow = row as ReturnOrderItem
            const statusInfo = getStatusTag(orderRow.status)
            return h(ElTag, { type: statusInfo.type }, { default: () => statusInfo.label })
          }
        },
        {
          prop: 'warehouse_name',
          label: '仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as ReturnOrderItem).warehouse_name || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ReturnOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ReturnOrderItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ReturnOrderItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteReturnOrder(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentReturnOrder.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: ReturnOrderItem) => {
    currentReturnOrder.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: ReturnOrderItem) => {
    currentReturnOrder.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteReturnOrder = (row: ReturnOrderItem) => {
    ElMessageBox.confirm(`确定删除退货单"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteWmsReturnOrderApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleReturnOrderCreated = (order: any) => {
    if (order?.id) refreshCreate()
  }

  const handleReturnOrderUpdated = (order: any) => {
    if (order?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: ReturnOrderItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的单据')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个单据吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionWmsReturnOrderApi({ actions: 'delete', ids: selectedIds })
        ElMessage.success('批量删除成功')
        refreshData()
        selectedRows.value = []
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleExport = () => {
    const elTableInstance = proTable.value?.elTableRef
    let _data: any = elTableInstance?.getSelectionRows() || data.value || []
    if (_data.length === 0) {
      ElMessage.warning('暂无数据可导出')
      return
    }
    exportExcel(columns.value, _data, '退货单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
