<!-- BOM副产品列表页面 -->
<template>
  <div class="art-full-height">
    <BomByproductSearch
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
              新建BOM副产品
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
        :data="data as BomByproductItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <BomByproductDialog
      v-model="dialogVisible"
      :bomByproduct="currentBomByproduct"
      :readonly="isViewMode"
      @created="handleBomByproductCreated"
      @updated="handleBomByproductUpdated"
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
  import BomByproductSearch from './modules/bom-byproduct-search.vue'
  import BomByproductDialog from './modules/bom-byproduct-dialog.vue'
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
  import { listMfgBomByproductApi, deleteMfgBomByproductApi } from '@/api/mfg/bom'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgBomByproduct' })

  interface BomByproductItem {
    id?: string | number
    bom_id?: string | number
    bom_code?: string
    product_id?: string | number
    product_name?: string
    product_qty?: number | string
    output_category?: string
    is_inventory?: boolean
    [key: string]: any
  }

  const searchForm = ref({
    bom_id_eq: undefined,
    product_id_eq: undefined,
    output_category_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentBomByproduct = ref<BomByproductItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<BomByproductItem[]>([])

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
      apiFn: listMfgBomByproductApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'bom_code',
          label: 'BOM编号',
          minWidth: 150,
          formatter: (row: unknown) => (row as BomByproductItem).bom_code || '-'
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as BomByproductItem).product_name || '-'
        },
        {
          prop: 'product_qty',
          label: '产品数量',
          minWidth: 120,
          formatter: (row: unknown) => (row as BomByproductItem).product_qty || '0.00'
        },
        {
          prop: 'output_category',
          label: '产出类别',
          minWidth: 120,
          formatter: (row: unknown) => {
            const item = row as BomByproductItem
            const categoryMap: Record<string, string> = {
              scrap: '废料',
              byproduct: '副产品'
            }
            return categoryMap[item.output_category || ''] || item.output_category || '-'
          }
        },
        {
          prop: 'is_inventory',
          label: '是否入库',
          minWidth: 100,
          formatter: (row: unknown) => {
            const item = row as BomByproductItem
            return h(
              ElTag,
              { type: item.is_inventory ? 'success' : 'info' },
              { default: () => (item.is_inventory ? '是' : '否') }
            )
          }
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as BomByproductItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as BomByproductItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: BomByproductItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteBomByproduct(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentBomByproduct.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: BomByproductItem) => {
    currentBomByproduct.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: BomByproductItem) => {
    currentBomByproduct.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteBomByproduct = (row: BomByproductItem) => {
    ElMessageBox.confirm(`确定删除BOM副产品吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgBomByproductApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleBomByproductCreated = (bomByproduct: any) => {
    if (bomByproduct?.id) refreshCreate()
  }

  const handleBomByproductUpdated = (bomByproduct: any) => {
    if (bomByproduct?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: BomByproductItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的BOM副产品')
      return
    }
    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个BOM副产品吗？`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        const deletePromises = selectedRows.value.map((row) =>
          deleteMfgBomByproductApi(Number(row.id))
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
    exportExcel(columns.value, _data, 'BOM副产品数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
