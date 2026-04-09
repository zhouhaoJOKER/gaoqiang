<!-- 工单损耗列表页面 -->
<template>
  <div class="art-full-height">
    <WorkOrderLossSearch
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
              新建工单损耗
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
        :data="data as WorkOrderLossItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <WorkOrderLossDialog
      v-model="dialogVisible"
      :workOrderLoss="currentWorkOrderLoss"
      :readonly="isViewMode"
      @created="handleWorkOrderLossCreated"
      @updated="handleWorkOrderLossUpdated"
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
  import WorkOrderLossSearch from './modules/work-order-loss-search.vue'
  import WorkOrderLossDialog from './modules/work-order-loss-dialog.vue'
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
  import { listMfgWorkOrderLossApi, deleteMfgWorkOrderLossApi } from '@/api/mfg/work-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgWorkOrderLoss' })

  interface WorkOrderLossItem {
    id?: string | number
    work_order_id?: string | number
    work_order_code?: string
    bom_loss_id?: string | number
    product_id?: string | number
    product_name?: string
    plan_loss_qty?: number | string
    actual_loss_qty?: number | string
    [key: string]: any
  }

  const searchForm = ref({
    work_order_id_eq: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentWorkOrderLoss = ref<WorkOrderLossItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<WorkOrderLossItem[]>([])

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
      apiFn: listMfgWorkOrderLossApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'work_order_code',
          label: '工单编号',
          minWidth: 150,
          formatter: (row: unknown) => (row as WorkOrderLossItem).work_order_code || '-'
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as WorkOrderLossItem).product_name || '-'
        },
        {
          prop: 'plan_loss_qty',
          label: '计划损耗',
          minWidth: 120,
          formatter: (row: unknown) => (row as WorkOrderLossItem).plan_loss_qty || '0.00'
        },
        {
          prop: 'actual_loss_qty',
          label: '实际损耗',
          minWidth: 120,
          formatter: (row: unknown) => (row as WorkOrderLossItem).actual_loss_qty || '0.00'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as WorkOrderLossItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as WorkOrderLossItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: WorkOrderLossItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteWorkOrderLoss(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentWorkOrderLoss.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: WorkOrderLossItem) => {
    currentWorkOrderLoss.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: WorkOrderLossItem) => {
    currentWorkOrderLoss.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteWorkOrderLoss = (row: WorkOrderLossItem) => {
    ElMessageBox.confirm(`确定删除工单损耗吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgWorkOrderLossApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleWorkOrderLossCreated = (workOrderLoss: any) => {
    if (workOrderLoss?.id) refreshCreate()
  }

  const handleWorkOrderLossUpdated = (workOrderLoss: any) => {
    if (workOrderLoss?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: WorkOrderLossItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的工单损耗')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个工单损耗吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const deletePromises = selectedRows.value.map((row) =>
          deleteMfgWorkOrderLossApi(Number(row.id))
        )
        await Promise.all(deletePromises)
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
    exportExcel(columns.value, _data, '工单损耗数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
