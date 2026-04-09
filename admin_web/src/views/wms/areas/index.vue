<!-- 库区列表页面 -->
<template>
  <div class="art-full-height">
    <AreaSearch
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
              新建库区
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
        :data="data as AreaItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <AreaDialog
      v-model="dialogVisible"
      :area="currentArea"
      :readonly="isViewMode"
      @created="handleAreaCreated"
      @updated="handleAreaUpdated"
    />

    <!-- 仓库创建对话框 -->
    <WarehouseDialog v-model="warehouseDialogVisible" @created="handleWarehouseCreated" />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import AreaSearch from './modules/area-search.vue'
  import AreaDialog from './modules/area-dialog.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
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
  import { listWmsAreaApi, deleteWmsAreaApi, batchActionWmsAreaApi } from '@/api/wms/area'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'WmsArea' })

  interface AreaItem {
    id?: string | number
    warehouse_id?: string | number
    warehouse_name?: string
    name?: string
    abbr?: string
    code?: string
    type_id?: string | number
    type_name?: string
    is_active?: boolean
    sort?: number | string
    description?: string
    py?: string
    pinyin?: string
    [key: string]: any
  }

  const searchForm = ref({
    name_cont: undefined,
    code_cont: undefined,
    warehouse_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentArea = ref<AreaItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<AreaItem[]>([])
  const warehouseDialogVisible = ref(false)

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
      apiFn: listWmsAreaApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '库区名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const areaRow = row as AreaItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(areaRow)
              },
              areaRow.name || ''
            )
          }
        },
        {
          prop: 'code',
          label: '库区编码',
          minWidth: 120,
          formatter: (row: unknown) => (row as AreaItem).code || '-'
        },
        {
          prop: 'warehouse_name',
          label: '所属仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as AreaItem).warehouse_name || '-'
        },
        {
          prop: 'is_active',
          label: '状态',
          minWidth: 80,
          formatter: (row: unknown) => {
            const areaRow = row as AreaItem
            return h(
              ElTag,
              { type: areaRow.is_active === false ? 'danger' : 'success' },
              { default: () => (areaRow.is_active === false ? '停用' : '启用') }
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as AreaItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑库区', icon: 'ri:edit-2-line' },
                  {
                    key: 'delete',
                    label: '删除库区',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as AreaItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: AreaItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteArea(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentArea.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: AreaItem) => {
    currentArea.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: AreaItem) => {
    currentArea.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteArea = (row: AreaItem) => {
    ElMessageBox.confirm(`确定删除库区"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteWmsAreaApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleWarehouseCreated = (warehouse: any) => {
    if (warehouse?.id) {
      // 刷新搜索栏的仓库选项
      ElMessage.success('仓库创建成功，请刷新搜索栏')
    }
  }

  const handleAreaCreated = (area: any) => {
    if (area?.id) refreshCreate()
  }

  const handleAreaUpdated = (area: any) => {
    if (area?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: AreaItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的库区')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个库区吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionWmsAreaApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '库区数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
