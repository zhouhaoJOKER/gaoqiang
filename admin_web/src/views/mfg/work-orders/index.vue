<!-- 工单列表页面 -->
<template>
  <div class="art-full-height">
    <WorkOrderSearch
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
              新建工单
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
        :data="data as WorkOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <WorkOrderDialog
      v-model="dialogVisible"
      :workOrder="currentWorkOrder"
      :readonly="isViewMode"
      @created="handleWorkOrderCreated"
      @updated="handleWorkOrderUpdated"
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
  import WorkOrderSearch from './modules/work-order-search.vue'
  import WorkOrderDialog from './modules/work-order-dialog.vue'
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
    listMfgWorkOrderApi,
    deleteMfgWorkOrderApi,
    batchActionMfgWorkOrderApi
  } from '@/api/mfg/work-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgWorkOrder' })

  interface WorkOrderItem {
    id?: string | number
    code?: string
    product_id?: string | number
    product_name?: string
    bom_id?: string | number
    plan_qty?: number | string
    actual_qty?: number | string
    status?: string
    plan_start?: string
    plan_finish?: string
    warehouse_id?: string | number
    warehouse_name?: string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    status_eq: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentWorkOrder = ref<WorkOrderItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<WorkOrderItem[]>([])

  type TagType = 'success' | 'danger' | 'warning' | 'info' | 'primary'
  const getStatusTag = (status?: string): { type: TagType; label: string } => {
    const statusMap: Record<string, { type: TagType; label: string }> = {
      draft: { type: 'info', label: '草稿' },
      confirmed: { type: 'primary', label: '已确认' },
      in_progress: { type: 'warning', label: '进行中' },
      completed: { type: 'success', label: '已完成' },
      cancelled: { type: 'danger', label: '已取消' }
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
      apiFn: listMfgWorkOrderApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '工单编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const orderRow = row as WorkOrderItem
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
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as WorkOrderItem).product_name || '-'
        },
        {
          prop: 'plan_qty',
          label: '计划数量',
          minWidth: 100,
          formatter: (row: unknown) => (row as WorkOrderItem).plan_qty || '0.00'
        },
        {
          prop: 'actual_qty',
          label: '实际数量',
          minWidth: 100,
          formatter: (row: unknown) => (row as WorkOrderItem).actual_qty || '0.00'
        },
        {
          prop: 'status',
          label: '状态',
          minWidth: 100,
          formatter: (row: unknown) => {
            const orderRow = row as WorkOrderItem
            const statusInfo = getStatusTag(orderRow.status)
            return h(ElTag, { type: statusInfo.type }, { default: () => statusInfo.label })
          }
        },
        {
          prop: 'plan_start',
          label: '计划开始',
          minWidth: 140,
          formatter: (row: unknown) => (row as WorkOrderItem).plan_start || '-'
        },
        {
          prop: 'plan_finish',
          label: '计划完成',
          minWidth: 140,
          formatter: (row: unknown) => (row as WorkOrderItem).plan_finish || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as WorkOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as WorkOrderItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: WorkOrderItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteWorkOrder(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentWorkOrder.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: WorkOrderItem) => {
    currentWorkOrder.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: WorkOrderItem) => {
    currentWorkOrder.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteWorkOrder = (row: WorkOrderItem) => {
    ElMessageBox.confirm(`确定删除工单"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgWorkOrderApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleWorkOrderCreated = (order: any) => {
    if (order?.id) refreshCreate()
  }

  const handleWorkOrderUpdated = (order: any) => {
    if (order?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: WorkOrderItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的工单')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个工单吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionMfgWorkOrderApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '工单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
