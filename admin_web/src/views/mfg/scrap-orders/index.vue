<!-- 报废单列表页面 -->
<template>
  <div class="art-full-height">
    <ScrapOrderSearch
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
              新建报废单
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
        :data="data as ScrapOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <ScrapOrderDialog
      v-model="dialogVisible"
      :scrapOrder="currentScrapOrder"
      :readonly="isViewMode"
      @created="handleScrapOrderCreated"
      @updated="handleScrapOrderUpdated"
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
  import ScrapOrderSearch from './modules/scrap-order-search.vue'
  import ScrapOrderDialog from './modules/scrap-order-dialog.vue'
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
    listMfgScrapOrderApi,
    deleteMfgScrapOrderApi,
    batchActionMfgScrapOrderApi
  } from '@/api/mfg/scrap-order'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgScrapOrder' })

  interface ScrapOrderItem {
    id?: string | number
    code?: string
    scrap_category?: string
    product_id?: string | number
    product_name?: string
    item_id?: string | number
    lot_id?: string | number
    location_id?: string | number
    location_name?: string
    planned_qty?: number | string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    scrap_category_eq: undefined,
    product_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentScrapOrder = ref<ScrapOrderItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<ScrapOrderItem[]>([])

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
      apiFn: listMfgScrapOrderApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '报废单编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const orderRow = row as ScrapOrderItem
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
          prop: 'scrap_category',
          label: '报废类别',
          minWidth: 120,
          formatter: (row: unknown) => (row as ScrapOrderItem).scrap_category || '-'
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as ScrapOrderItem).product_name || '-'
        },
        {
          prop: 'planned_qty',
          label: '计划数量',
          minWidth: 100,
          formatter: (row: unknown) => (row as ScrapOrderItem).planned_qty || '0.00'
        },
        {
          prop: 'location_name',
          label: '货位',
          minWidth: 120,
          formatter: (row: unknown) => (row as ScrapOrderItem).location_name || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ScrapOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ScrapOrderItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ScrapOrderItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteScrapOrder(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentScrapOrder.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: ScrapOrderItem) => {
    currentScrapOrder.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: ScrapOrderItem) => {
    currentScrapOrder.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteScrapOrder = (row: ScrapOrderItem) => {
    ElMessageBox.confirm(`确定删除报废单"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgScrapOrderApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleScrapOrderCreated = (order: any) => {
    if (order?.id) refreshCreate()
  }

  const handleScrapOrderUpdated = (order: any) => {
    if (order?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: ScrapOrderItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的报废单')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个报废单吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionMfgScrapOrderApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '报废单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
