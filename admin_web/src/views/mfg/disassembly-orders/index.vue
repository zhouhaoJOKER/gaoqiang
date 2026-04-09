<!-- 拆解单列表页面 -->
<template>
  <div class="art-full-height">
    <DisassemblyOrderSearch
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
              新建拆解单
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
        :data="data as DisassemblyOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <DisassemblyOrderDialog
      v-model="dialogVisible"
      :disassemblyOrder="currentDisassemblyOrder"
      :readonly="isViewMode"
      @created="handleDisassemblyOrderCreated"
      @updated="handleDisassemblyOrderUpdated"
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
  import DisassemblyOrderSearch from './modules/disassembly-order-search.vue'
  import DisassemblyOrderDialog from './modules/disassembly-order-dialog.vue'
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
    listMfgDisassemblyOrderApi,
    deleteMfgDisassemblyOrderApi,
    batchActionMfgDisassemblyOrderApi
  } from '@/api/mfg/disassembly-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgDisassemblyOrder' })

  interface DisassemblyOrderItem {
    id?: string | number
    code?: string
    product_id?: string | number
    product_name?: string
    item_id?: string | number
    lot_id?: string | number
    planned_qty?: number | string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentDisassemblyOrder = ref<DisassemblyOrderItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<DisassemblyOrderItem[]>([])

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
      apiFn: listMfgDisassemblyOrderApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '拆解单编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const orderRow = row as DisassemblyOrderItem
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
          formatter: (row: unknown) => (row as DisassemblyOrderItem).product_name || '-'
        },
        {
          prop: 'planned_qty',
          label: '计划数量',
          minWidth: 100,
          formatter: (row: unknown) => (row as DisassemblyOrderItem).planned_qty || '0.00'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as DisassemblyOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) =>
                  buttonMoreClick(item, row as DisassemblyOrderItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: DisassemblyOrderItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteDisassemblyOrder(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentDisassemblyOrder.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: DisassemblyOrderItem) => {
    currentDisassemblyOrder.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: DisassemblyOrderItem) => {
    currentDisassemblyOrder.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteDisassemblyOrder = (row: DisassemblyOrderItem) => {
    ElMessageBox.confirm(`确定删除拆解单"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgDisassemblyOrderApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleDisassemblyOrderCreated = (order: any) => {
    if (order?.id) refreshCreate()
  }

  const handleDisassemblyOrderUpdated = (order: any) => {
    if (order?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: DisassemblyOrderItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的拆解单')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个拆解单吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionMfgDisassemblyOrderApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '拆解单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
