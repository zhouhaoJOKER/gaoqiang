<!-- 工单副产品列表页面 -->
<template>
  <div class="art-full-height">
    <WorkOrderByproductSearch
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
              新建工单副产品
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
        :data="data as WorkOrderByproductItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <WorkOrderByproductDialog
      v-model="dialogVisible"
      :workOrderByproduct="currentWorkOrderByproduct"
      :readonly="isViewMode"
      @created="handleWorkOrderByproductCreated"
      @updated="handleWorkOrderByproductUpdated"
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
  import WorkOrderByproductSearch from './modules/work-order-byproduct-search.vue'
  import WorkOrderByproductDialog from './modules/work-order-byproduct-dialog.vue'
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
    listMfgWorkOrderByproductApi,
    deleteMfgWorkOrderByproductApi
  } from '@/api/mfg/work-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgWorkOrderByproduct' })

  interface WorkOrderByproductItem {
    id?: string | number
    work_order_id?: string | number
    work_order_code?: string
    bom_byproduct_id?: string | number
    product_id?: string | number
    product_name?: string
    plan_qty?: number | string
    actual_qty?: number | string
    [key: string]: any
  }

  const searchForm = ref({
    work_order_id_eq: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentWorkOrderByproduct = ref<WorkOrderByproductItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<WorkOrderByproductItem[]>([])

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
      apiFn: listMfgWorkOrderByproductApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'work_order_code',
          label: '工单编号',
          minWidth: 150,
          formatter: (row: unknown) => (row as WorkOrderByproductItem).work_order_code || '-'
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as WorkOrderByproductItem).product_name || '-'
        },
        {
          prop: 'plan_qty',
          label: '计划数量',
          minWidth: 120,
          formatter: (row: unknown) => (row as WorkOrderByproductItem).plan_qty || '0.00'
        },
        {
          prop: 'actual_qty',
          label: '实际数量',
          minWidth: 120,
          formatter: (row: unknown) => (row as WorkOrderByproductItem).actual_qty || '0.00'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as WorkOrderByproductItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) =>
                  buttonMoreClick(item, row as WorkOrderByproductItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: WorkOrderByproductItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteWorkOrderByproduct(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentWorkOrderByproduct.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: WorkOrderByproductItem) => {
    currentWorkOrderByproduct.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: WorkOrderByproductItem) => {
    currentWorkOrderByproduct.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteWorkOrderByproduct = (row: WorkOrderByproductItem) => {
    ElMessageBox.confirm(`确定删除工单副产品吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgWorkOrderByproductApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleWorkOrderByproductCreated = (workOrderByproduct: any) => {
    if (workOrderByproduct?.id) refreshCreate()
  }

  const handleWorkOrderByproductUpdated = (workOrderByproduct: any) => {
    if (workOrderByproduct?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: WorkOrderByproductItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的工单副产品')
      return
    }
    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个工单副产品吗？`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        const deletePromises = selectedRows.value.map((row) =>
          deleteMfgWorkOrderByproductApi(Number(row.id))
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
    exportExcel(columns.value, _data, '工单副产品数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
