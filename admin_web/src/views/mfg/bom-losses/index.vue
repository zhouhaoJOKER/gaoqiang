<!-- BOM损耗列表页面 -->
<template>
  <div class="art-full-height">
    <BomLossSearch
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
              新建BOM损耗
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
        :data="data as BomLossItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <BomLossDialog
      v-model="dialogVisible"
      :bomLoss="currentBomLoss"
      :readonly="isViewMode"
      @created="handleBomLossCreated"
      @updated="handleBomLossUpdated"
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
  import BomLossSearch from './modules/bom-loss-search.vue'
  import BomLossDialog from './modules/bom-loss-dialog.vue'
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
  import { listMfgBomLossApi, deleteMfgBomLossApi } from '@/api/mfg/bom'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'MfgBomLoss' })

  interface BomLossItem {
    id?: string | number
    bom_line_id?: string | number
    bom_line_name?: string
    loss_mode?: string
    loss_value?: number | string
    [key: string]: any
  }

  const searchForm = ref({
    bom_line_id_eq: undefined,
    loss_mode_eq: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentBomLoss = ref<BomLossItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<BomLossItem[]>([])

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
      apiFn: listMfgBomLossApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'bom_line_name',
          label: 'BOM明细行',
          minWidth: 150,
          formatter: (row: unknown) => (row as BomLossItem).bom_line_name || '-'
        },
        {
          prop: 'loss_mode',
          label: '损耗模式',
          minWidth: 120,
          formatter: (row: unknown) => {
            const item = row as BomLossItem
            const modeMap: Record<string, string> = {
              percent: '百分比',
              fixed: '固定值'
            }
            return modeMap[item.loss_mode || ''] || item.loss_mode || '-'
          }
        },
        {
          prop: 'loss_value',
          label: '损耗值',
          minWidth: 120,
          formatter: (row: unknown) => (row as BomLossItem).loss_value || '0.00'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as BomLossItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as BomLossItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: BomLossItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteBomLoss(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentBomLoss.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: BomLossItem) => {
    currentBomLoss.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: BomLossItem) => {
    currentBomLoss.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteBomLoss = (row: BomLossItem) => {
    ElMessageBox.confirm(`确定删除BOM损耗吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMfgBomLossApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleBomLossCreated = (bomLoss: any) => {
    if (bomLoss?.id) refreshCreate()
  }

  const handleBomLossUpdated = (bomLoss: any) => {
    if (bomLoss?.id) refreshUpdate()
  }

  const handleSelectionChange = (selection: BomLossItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的BOM损耗')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个BOM损耗吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const deletePromises = selectedRows.value.map((row) => deleteMfgBomLossApi(Number(row.id)))
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
    exportExcel(columns.value, _data, 'BOM损耗数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
