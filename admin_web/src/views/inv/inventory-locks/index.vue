<!-- 库存锁定列表页面 -->
<template>
  <div class="art-full-height">
    <InventoryLockSearch
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
              新建库存锁定
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
        :data="data as InventoryLockItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <InventoryLockDialog
      v-model="dialogVisible"
      :inventoryLock="currentInventoryLock"
      :readonly="isViewMode"
      @created="handleInventoryLockCreated"
      @updated="handleInventoryLockUpdated"
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
  import InventoryLockSearch from './modules/inventory-lock-search.vue'
  import InventoryLockDialog from './modules/inventory-lock-dialog.vue'
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
    listInvInventoryLockApi,
    deleteInvInventoryLockApi,
    batchActionInvInventoryLockApi
  } from '@/api/inv/inventory-lock'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'InvInventoryLock' })

  interface InventoryLockItem {
    id?: string | number
    item_id?: string | number
    item_name?: string
    location_id?: string | number
    location_name?: string
    locked_qty?: number | string
    order_type?: string
    order_id?: string | number
    lock_type?: string
    status?: string
    expires_at?: string
    [key: string]: any
  }

  const searchForm = ref({
    item_id_eq: undefined,
    location_id_eq: undefined,
    order_type_eq: undefined,
    status_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentInventoryLock = ref<InventoryLockItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<InventoryLockItem[]>([])

  type TagType = 'success' | 'danger' | 'warning' | 'info' | 'primary'
  const getStatusTag = (status?: string): { type: TagType; label: string } => {
    const statusMap: Record<string, { type: TagType; label: string }> = {
      active: { type: 'success', label: '有效' },
      expired: { type: 'danger', label: '已过期' },
      released: { type: 'info', label: '已释放' }
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
      apiFn: listInvInventoryLockApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'item_name',
          label: '物品',
          minWidth: 150,
          formatter: (row: unknown) => {
            const lockRow = row as InventoryLockItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(lockRow)
              },
              lockRow.item_name || '-'
            )
          }
        },
        {
          prop: 'location_name',
          label: '货位',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryLockItem).location_name || '-'
        },
        {
          prop: 'locked_qty',
          label: '锁定数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const lockRow = row as InventoryLockItem
            return Number(lockRow.locked_qty || 0).toFixed(2)
          }
        },
        {
          prop: 'order_type',
          label: '订单类型',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryLockItem).order_type || '-'
        },
        {
          prop: 'order_id',
          label: '订单ID',
          minWidth: 100,
          formatter: (row: unknown) => (row as InventoryLockItem).order_id || '-'
        },
        {
          prop: 'lock_type',
          label: '锁定类型',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryLockItem).lock_type || '-'
        },
        {
          prop: 'status',
          label: '状态',
          minWidth: 100,
          formatter: (row: unknown) => {
            const lockRow = row as InventoryLockItem
            const statusInfo = getStatusTag(lockRow.status)
            return h(ElTag, { type: statusInfo.type }, { default: () => statusInfo.label })
          }
        },
        {
          prop: 'expires_at',
          label: '过期时间',
          minWidth: 160,
          formatter: (row: unknown) => (row as InventoryLockItem).expires_at || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as InventoryLockItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as InventoryLockItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: InventoryLockItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteInventoryLock(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentInventoryLock.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: InventoryLockItem) => {
    currentInventoryLock.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: InventoryLockItem) => {
    currentInventoryLock.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteInventoryLock = (row: InventoryLockItem) => {
    ElMessageBox.confirm(`确定删除库存锁定记录吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteInvInventoryLockApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleInventoryLockCreated = (lock: any) => {
    if (lock?.id) refreshCreate()
  }

  const handleInventoryLockUpdated = (lock: any) => {
    if (lock?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: InventoryLockItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的锁定记录')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 条锁定记录吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionInvInventoryLockApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '库存锁定数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
