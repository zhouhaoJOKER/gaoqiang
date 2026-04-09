<!-- BOM列表页面 -->
<template>
  <div class="art-full-height">
    <BomSearch
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
              新建BOM
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
        :data="data as BomItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <BomDialog
      v-model="dialogVisible"
      :bom="currentBom"
      :readonly="isViewMode"
      @created="handleBomCreated"
      @updated="handleBomUpdated"
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
  import BomSearch from './modules/bom-search.vue'
  import BomDialog from './modules/bom-dialog.vue'
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
  import { listMfgBomApi, deleteMfgBomApi, batchActionMfgBomApi } from '@/api/mfg/bom'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgBom' })

  interface BomItem {
    id?: string | number
    code?: string
    product_id?: string | number
    product_name?: string
    type_id?: number
    type?: {
      name: string
      color?: string
      abbr?: string
      [key: string]: any
    }
    product_qty?: number | string
    is_active?: boolean
    is_default?: boolean
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    product_id_eq: undefined,
    type_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentBom = ref<BomItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<BomItem[]>([])

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
      apiFn: listMfgBomApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: 'BOM编号',
          minWidth: 150,
          formatter: (row: unknown) => {
            const bomRow = row as BomItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(bomRow)
              },
              bomRow.code || '-'
            )
          }
        },
        {
          prop: 'product_name',
          label: '产品',
          minWidth: 150,
          formatter: (row: unknown) => (row as BomItem).product_name || '-'
        },
        {
          prop: 'type',
          label: '类型',
          minWidth: 100,
          formatter: (row: unknown) => {
            const bomRow = row as BomItem
            const typeData = bomRow.type as any
            if (typeData && typeof typeData === 'object') {
              return h(
                ElTag,
                {
                  type: typeData.color || 'info',
                  effect: 'light'
                },
                { default: () => typeData.name || '-' }
              )
            }
            return h('span', {}, typeData || '-')
          }
        },
        {
          prop: 'product_qty',
          label: '产品数量',
          minWidth: 100,
          formatter: (row: unknown) => (row as BomItem).product_qty || '0.00'
        },
        {
          prop: 'is_active',
          label: '状态',
          minWidth: 80,
          formatter: (row: unknown) => {
            const bomRow = row as BomItem
            return h(
              ElTag,
              { type: bomRow.is_active === false ? 'danger' : 'success' },
              { default: () => (bomRow.is_active === false ? '停用' : '启用') }
            )
          }
        },
        {
          prop: 'is_default',
          label: '默认',
          minWidth: 80,
          formatter: (row: unknown) => {
            const bomRow = row as BomItem
            return h(
              ElTag,
              { type: bomRow.is_default ? 'success' : 'info' },
              { default: () => (bomRow.is_default ? '是' : '否') }
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as BomItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as BomItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: BomItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteBom(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentBom.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: BomItem) => {
    currentBom.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: BomItem) => {
    currentBom.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteBom = (row: BomItem) => {
    ElMessageBox.confirm(`确定删除BOM"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgBomApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleBomCreated = (bom: any) => {
    if (bom?.id) refreshCreate()
  }

  const handleBomUpdated = (bom: any) => {
    if (bom?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: BomItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的BOM')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个BOM吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionMfgBomApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, 'BOM数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
