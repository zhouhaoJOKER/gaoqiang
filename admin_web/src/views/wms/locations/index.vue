<!-- 货位列表页面 -->
<template>
  <div class="art-full-height">
    <LocationSearch
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
              新建货位
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
        :data="data as LocationItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <LocationDialog
      v-model="dialogVisible"
      :location="currentLocation"
      :readonly="isViewMode"
      @created="handleLocationCreated"
      @updated="handleLocationUpdated"
    />

    <!-- 仓库创建对话框 -->
    <WarehouseDialog v-model="warehouseDialogVisible" @created="handleWarehouseCreated" />

    <!-- 库区创建对话框 -->
    <AreaDialog v-model="areaDialogVisible" @created="handleAreaCreated" />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import LocationSearch from './modules/location-search.vue'
  import LocationDialog from './modules/location-dialog.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import AreaDialog from '@/views/wms/areas/modules/area-dialog.vue'
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
    listWmsLocationApi,
    deleteWmsLocationApi,
    batchActionWmsLocationApi
  } from '@/api/wms/location'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'WmsLocation' })

  interface LocationItem {
    id?: string | number
    warehouse_id?: string | number
    warehouse_name?: string
    area_id?: string | number
    area_name?: string
    name?: string
    abbr?: string
    code?: string
    type_id?: string | number
    is_active?: boolean
    is_adjustment?: boolean
    is_reservation?: boolean
    sort?: number | string
    description?: string
    py?: string
    pinyin?: string
    [key: string]: any
  }

  const searchForm = ref({
    name_cont: undefined,
    code_cont: undefined,
    warehouse_id_eq: undefined,
    area_id_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentLocation = ref<LocationItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<LocationItem[]>([])
  const warehouseDialogVisible = ref(false)
  const areaDialogVisible = ref(false)

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
      apiFn: listWmsLocationApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '货位名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const locationRow = row as LocationItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(locationRow)
              },
              locationRow.name || ''
            )
          }
        },
        {
          prop: 'code',
          label: '货位编码',
          minWidth: 120,
          formatter: (row: unknown) => (row as LocationItem).code || '-'
        },
        {
          prop: 'warehouse_name',
          label: '所属仓库',
          minWidth: 120,
          formatter: (row: unknown) => (row as LocationItem).warehouse_name || '-'
        },
        {
          prop: 'area_name',
          label: '所属库区',
          minWidth: 120,
          formatter: (row: unknown) => (row as LocationItem).area_name || '-'
        },
        {
          prop: 'is_active',
          label: '状态',
          minWidth: 80,
          formatter: (row: unknown) => {
            const locationRow = row as LocationItem
            return h(
              ElTag,
              { type: locationRow.is_active === false ? 'danger' : 'success' },
              { default: () => (locationRow.is_active === false ? '停用' : '启用') }
            )
          }
        },
        {
          prop: 'is_adjustment',
          label: '可调整',
          minWidth: 80,
          formatter: (row: unknown) => {
            const locationRow = row as LocationItem
            return h(
              ElTag,
              { type: locationRow.is_adjustment ? 'success' : 'info' },
              { default: () => (locationRow.is_adjustment ? '是' : '否') }
            )
          }
        },
        {
          prop: 'is_reservation',
          label: '可预留',
          minWidth: 80,
          formatter: (row: unknown) => {
            const locationRow = row as LocationItem
            return h(
              ElTag,
              { type: locationRow.is_reservation ? 'success' : 'info' },
              { default: () => (locationRow.is_reservation ? '是' : '否') }
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as LocationItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑货位', icon: 'ri:edit-2-line' },
                  {
                    key: 'delete',
                    label: '删除货位',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as LocationItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: LocationItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteLocation(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentLocation.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleWarehouseCreated = (warehouse: any) => {
    if (warehouse?.id) {
      ElMessage.success('仓库创建成功，请刷新搜索栏')
    }
  }

  const handleAreaCreated = (area: any) => {
    if (area?.id) {
      ElMessage.success('库区创建成功，请刷新搜索栏')
    }
  }

  const handleView = (row?: LocationItem) => {
    currentLocation.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: LocationItem) => {
    currentLocation.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteLocation = (row: LocationItem) => {
    ElMessageBox.confirm(`确定删除货位"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteWmsLocationApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleLocationCreated = (location: any) => {
    if (location?.id) refreshCreate()
  }

  const handleLocationUpdated = (location: any) => {
    if (location?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: LocationItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的货位')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个货位吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const selectedIds = selectedRows.value.map((row) => row.id).filter(Boolean)
        await batchActionWmsLocationApi({ actions: 'delete', ids: selectedIds })
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
    exportExcel(columns.value, _data, '货位数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
