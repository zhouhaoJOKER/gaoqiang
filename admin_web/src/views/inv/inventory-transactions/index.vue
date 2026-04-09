<!-- 库存流水列表页面 -->
<template>
  <div class="art-full-height">
    <InventoryTransactionSearch
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
              新建流水
            </ElButton>
            <ElDropdown trigger="click">
              <ElButton type="default" v-ripple>
                <ArtSvgIcon icon="ri:more-2-line" />
                更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
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
        :data="data as InventoryTransactionItem[]"
        :columns="columns"
        :pagination="pagination"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <InventoryTransactionDialog
      v-model="dialogVisible"
      :transaction="currentTransaction"
      :readonly="true"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import InventoryTransactionSearch from './modules/inventory-transaction-search.vue'
  import InventoryTransactionDialog from './modules/inventory-transaction-dialog.vue'
  import {
    ElButton,
    ElCard,
    ElMessage,
    ElSpace,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon,
    ElTag
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { listInvInventoryTransactionApi } from '@/api/inv/inventory-transaction'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'InvInventoryTransaction' })

  interface InventoryTransactionItem {
    id?: string | number
    code?: string
    item_id?: string | number
    item_name?: string
    location_id?: string | number
    location_name?: string
    transaction_type?: string
    related_order_type?: string
    quantity_before?: number | string
    quantity_change?: number | string
    quantity_after?: number | string
    transaction_time?: string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    transaction_type_eq: undefined,
    item_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentTransaction = ref<InventoryTransactionItem | undefined>(undefined)

  type TagType = 'success' | 'danger' | 'warning' | 'info' | 'primary'
  const getTransactionTypeTag = (type?: string): { type: TagType; label: string } => {
    const typeMap: Record<string, { type: TagType; label: string }> = {
      in: { type: 'success', label: '入库' },
      out: { type: 'danger', label: '出库' },
      transfer: { type: 'warning', label: '调拨' },
      adjust: { type: 'info', label: '调整' }
    }
    return typeMap[type || ''] || { type: 'info', label: type || '-' }
  }

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    getData,
    searchParams,
    resetSearchParams,
    handleSizeChange,
    handleCurrentChange,
    refreshData
  } = useTable({
    core: {
      apiFn: listInvInventoryTransactionApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '流水编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const transactionRow = row as InventoryTransactionItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(transactionRow)
              },
              transactionRow.code || '-'
            )
          }
        },
        {
          prop: 'item_name',
          label: '物品',
          minWidth: 150,
          formatter: (row: unknown) => (row as InventoryTransactionItem).item_name || '-'
        },
        {
          prop: 'location_name',
          label: '货位',
          minWidth: 120,
          formatter: (row: unknown) => (row as InventoryTransactionItem).location_name || '-'
        },
        {
          prop: 'transaction_type',
          label: '流水类型',
          minWidth: 100,
          formatter: (row: unknown) => {
            const transactionRow = row as InventoryTransactionItem
            const typeInfo = getTransactionTypeTag(transactionRow.transaction_type)
            return h(ElTag, { type: typeInfo.type }, { default: () => typeInfo.label })
          }
        },
        {
          prop: 'quantity_before',
          label: '变动前数量',
          minWidth: 120,
          formatter: (row: unknown) => {
            const transactionRow = row as InventoryTransactionItem
            return Number(transactionRow.quantity_before || 0).toFixed(2)
          }
        },
        {
          prop: 'quantity_change',
          label: '变动数量',
          minWidth: 120,
          formatter: (row: unknown) => {
            const transactionRow = row as InventoryTransactionItem
            const change = Number(transactionRow.quantity_change || 0)
            const color = change > 0 ? 'success' : change < 0 ? 'danger' : 'info'
            return h(
              ElTag,
              { type: color },
              { default: () => (change > 0 ? '+' : '') + change.toFixed(2) }
            )
          }
        },
        {
          prop: 'quantity_after',
          label: '变动后数量',
          minWidth: 120,
          formatter: (row: unknown) => {
            const transactionRow = row as InventoryTransactionItem
            return Number(transactionRow.quantity_after || 0).toFixed(2)
          }
        },
        {
          prop: 'transaction_time',
          label: '流水时间',
          minWidth: 160,
          formatter: (row: unknown) => (row as InventoryTransactionItem).transaction_time || '-'
        },
        {
          prop: 'operation',
          label: '操作',
          width: 60,
          fixed: 'right',
          formatter: (row: unknown) =>
            h(ArtButtonTable, {
              type: 'view',
              onClick: () => handleView(row as InventoryTransactionItem)
            })
        }
      ]
    }
  })

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    // 库存流水通常由系统自动创建，但保留创建功能
    currentTransaction.value = undefined
    dialogVisible.value = true
  }

  const handleView = (row?: InventoryTransactionItem) => {
    currentTransaction.value = row
    dialogVisible.value = true
  }

  const handleExport = () => {
    let _data: any = data.value || []
    if (_data.length === 0) {
      ElMessage.warning('暂无数据可导出')
      return
    }
    exportExcel(columns.value, _data, '库存流水数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
