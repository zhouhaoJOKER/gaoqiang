<!-- 库存列表页面 -->
<template>
  <div class="art-full-height">
    <InventorySearch
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
              新建库存
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
        :data="data as InventoryItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <InventoryDialog
      v-model="dialogVisible"
      :inventory="currentInventory"
      :readonly="isViewMode"
      @created="handleInventoryCreated"
      @updated="handleInventoryUpdated"
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
  import InventorySearch from './modules/inventory-search.vue'
  import InventoryDialog from './modules/inventory-dialog.vue'
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
    listInvInventoryApi,
    deleteInvInventoryApi,
    batchActionInvInventoryApi
  } from '@/api/inv/inventory'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'InvInventory' })

  interface InventoryItem {
    id?: string | number
    item_id?: string | number
    item_name?: string
    location_id?: string | number
    location_name?: string
    warehouse_id?: string | number
    warehouse_name?: string
    on_hand_qty?: number | string
    available_qty?: number | string
    allocated_qty?: number | string
    in_transit_qty?: number | string
    status_id?: string | number
    last_count_date?: string
    [key: string]: any
  }

  const searchForm = ref({
    item_id_eq: undefined,
    location_id_eq: undefined,
    warehouse_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentInventory = ref<InventoryItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<InventoryItem[]>([])

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
      apiFn: listInvInventoryApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'item_name',
          label: '物品',
          minWidth: 150,
          formatter: (row: unknown) => {
            const inventoryRow = row as InventoryItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(inventoryRow)
              },
              inventoryRow.item_name || '-'
            )
          }
        },
        {
          prop: 'warehouse_name',
          label: '仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryItem).warehouse_name || '-'
        },
        {
          prop: 'location_name',
          label: '货位',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryItem).location_name || '-'
        },
        {
          prop: 'on_hand_qty',
          label: '在手数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const inventoryRow = row as InventoryItem
            return Number(inventoryRow.on_hand_qty || 0).toFixed(2)
          }
        },
        {
          prop: 'available_qty',
          label: '可用数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const inventoryRow = row as InventoryItem
            return Number(inventoryRow.available_qty || 0).toFixed(2)
          }
        },
        {
          prop: 'allocated_qty',
          label: '分配数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const inventoryRow = row as InventoryItem
            return Number(inventoryRow.allocated_qty || 0).toFixed(2)
          }
        },
        {
          prop: 'in_transit_qty',
          label: '在途数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const inventoryRow = row as InventoryItem
            return Number(inventoryRow.in_transit_qty || 0).toFixed(2)
          }
        },
        {
          prop: 'last_count_date',
          label: '最后盘点日期',
          minWidth: 140,
          formatter: (row: unknown) => (row as InventoryItem).last_count_date || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as InventoryItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as InventoryItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: InventoryItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteInventory(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentInventory.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: InventoryItem) => {
    currentInventory.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: InventoryItem) => {
    currentInventory.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteInventory = (row: InventoryItem) => {
    ElMessageBox.confirm(`确定删除库存记录吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteInvInventoryApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleInventoryCreated = (inventory: any) => {
    if (inventory?.id) refreshCreate()
  }

  const handleInventoryUpdated = (inventory: any) => {
    if (inventory?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: InventoryItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的库存记录')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 条库存记录吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionInvInventoryApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '库存数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
