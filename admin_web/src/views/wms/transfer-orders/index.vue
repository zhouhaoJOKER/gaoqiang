<!-- 调拨单列表页面 -->
<template>
  <div class="art-full-height">
    <TransferOrderSearch
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
              新建调拨单
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
        :data="data as TransferOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <TransferOrderDialog
      v-model="dialogVisible"
      :transferOrder="currentTransferOrder"
      :readonly="isViewMode"
      @created="handleTransferOrderCreated"
      @updated="handleTransferOrderUpdated"
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
  import TransferOrderSearch from './modules/transfer-order-search.vue'
  import TransferOrderDialog from './modules/transfer-order-dialog.vue'
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
    listWmsTransferOrderApi,
    deleteWmsTransferOrderApi,
    batchActionWmsTransferOrderApi
  } from '@/api/wms/transfer-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'WmsTransferOrder' })

  interface TransferOrderItem {
    id?: string | number
    code?: string
    transfer_type?: string
    status?: string
    from_warehouse_id?: string | number
    from_warehouse_name?: string
    to_warehouse_id?: string | number
    to_warehouse_name?: string
    move_category?: string
    plan_date?: string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    status_eq: undefined,
    transfer_type_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentTransferOrder = ref<TransferOrderItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<TransferOrderItem[]>([])

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
      apiFn: listWmsTransferOrderApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '单据编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const orderRow = row as TransferOrderItem
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
          prop: 'transfer_type',
          label: '调拨类型',
          minWidth: 120,
          formatter: (row: unknown) => {
            const orderRow = row as TransferOrderItem
            const typeMap: Record<string, string> = {
              internal: '内部调拨',
              cross_company: '跨公司调拨'
            }
            return typeMap[orderRow.transfer_type || ''] || orderRow.transfer_type || '-'
          }
        },
        {
          prop: 'status',
          label: '状态',
          minWidth: 100,
          formatter: (row: unknown) => {
            const orderRow = row as TransferOrderItem
            const statusInfo = getStatusTag(orderRow.status)
            return h(ElTag, { type: statusInfo.type }, { default: () => statusInfo.label })
          }
        },
        {
          prop: 'from_warehouse_name',
          label: '源仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as TransferOrderItem).from_warehouse_name || '-'
        },
        {
          prop: 'to_warehouse_name',
          label: '目标仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as TransferOrderItem).to_warehouse_name || '-'
        },
        {
          prop: 'plan_date',
          label: '计划日期',
          minWidth: 120,
          formatter: (row: unknown) => (row as TransferOrderItem).plan_date || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as TransferOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as TransferOrderItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: TransferOrderItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteTransferOrder(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentTransferOrder.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: TransferOrderItem) => {
    currentTransferOrder.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: TransferOrderItem) => {
    currentTransferOrder.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteTransferOrder = (row: TransferOrderItem) => {
    ElMessageBox.confirm(`确定删除调拨单"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteWmsTransferOrderApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleTransferOrderCreated = (order: any) => {
    if (order?.id) refreshCreate()
  }

  const handleTransferOrderUpdated = (order: any) => {
    if (order?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: TransferOrderItem[]) => {
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
        await batchActionWmsTransferOrderApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '调拨单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
