<template>
  <div class="art-full-height">
    <RawInspectionSearch
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
            <ElButton type="primary" @click="handleCreate" v-ripple
              ><ArtSvgIcon icon="ri:add-line" /> 新建原料检验</ElButton
            >
            <ElDropdown trigger="click">
              <ElButton type="default" v-ripple
                ><ArtSvgIcon icon="ri:more-2-line" /> 更多
                <ElIcon class="el-icon--right"><ArrowDown /></ElIcon
              ></ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem @click="handleBatchDelete"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                    批量删除</ElDropdownItem
                  >
                  <ElDropdownItem divided></ElDropdownItem>
                  <ElDropdownItem @click="handleExport"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                    导出</ElDropdownItem
                  >
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </ElSpace>
        </template>
      </ArtTableHeader>
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as RawInspectionItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <RawInspectionDialog
      v-model="dialogVisible"
      :raw="currentRaw"
      :readonly="isViewMode"
      @created="handleCreated"
      @updated="handleUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import RawInspectionSearch from './modules/raw-inspection-search.vue'
  import RawInspectionDialog from './modules/raw-inspection-dialog.vue'
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
  import { listIqcRawApi, deleteIqcRawApi, batchActionIqcRawApi } from '@/api/iqc/raw'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'IqcRawInspection' })
  const router = useRouter()

  interface RawInspectionItem {
    id?: string | number
    code?: string
    name?: string
    product_id?: string | number
    batch_number?: string
    inspection_date?: string
    conclusion?: string
    [key: string]: any
  }

  const searchForm = ref({
    code_cont: undefined,
    product_id_eq: undefined,
    conclusion_eq: undefined
  })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentRaw = ref<RawInspectionItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<RawInspectionItem[]>([])

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
      apiFn: listIqcRawApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '检验编号',
          minWidth: 130,
          formatter: (row: unknown) => {
            const r = row as RawInspectionItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.code || '-'
            )
          }
        },
        {
          prop: 'name',
          label: '原料名称',
          minWidth: 140,
          formatter: (row: unknown) => (row as RawInspectionItem).name || '-'
        },
        {
          prop: 'batch_number',
          label: '原料批号',
          minWidth: 120,
          formatter: (row: unknown) => (row as RawInspectionItem).batch_number || '-'
        },
        {
          prop: 'inspection_date',
          label: '检验日期',
          minWidth: 120,
          formatter: (row: unknown) => (row as RawInspectionItem).inspection_date || '-'
        },
        {
          prop: 'conclusion',
          label: '结论',
          minWidth: 90,
          formatter: (row: unknown) => {
            const r = row as RawInspectionItem
            const c = r.conclusion || '-'
            return h(
              'span',
              { class: c === '合格' ? 'text-green-600' : c === '不合格' ? 'text-red-600' : '' },
              c
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as RawInspectionItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as RawInspectionItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: RawInspectionItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteRaw(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentRaw.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: RawInspectionItem) => {
    if (row?.id) router.push({ path: `/iqc/raw-inspections/${row.id}` })
  }
  const handleEdit = (row?: RawInspectionItem) => {
    currentRaw.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteRaw = (row: RawInspectionItem) => {
    ElMessageBox.confirm(`确定删除原料检验"${row.code || row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteIqcRawApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleCreated = () => refreshCreate()
  const handleUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: RawInspectionItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的原料检验')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 条原料检验吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionIqcRawApi({
          actions: 'delete',
          ids: selectedRows.value.map((r) => r.id).filter(Boolean)
        })
        ElMessage.success('批量删除成功')
        refreshData()
        selectedRows.value = []
      })
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleExport = () => {
    const _data: any = data.value || []
    if (_data.length === 0) {
      ElMessage.warning('暂无数据可导出')
      return
    }
    exportExcel(columns.value, _data, '原料检验数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
