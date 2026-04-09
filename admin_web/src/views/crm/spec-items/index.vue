<template>
  <div class="art-full-height">
    <SpecItemSearch
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
              ><ArtSvgIcon icon="ri:add-line" /> 新建指标项目</ElButton
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
        :data="data as SpecItemRow[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <SpecItemDialog
      v-model="dialogVisible"
      :spec-item="currentSpecItem"
      :readonly="isViewMode"
      @created="handleSpecItemCreated"
      @updated="handleSpecItemUpdated"
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
  import SpecItemSearch from './modules/spec-item-search.vue'
  import SpecItemDialog from './modules/spec-item-dialog.vue'
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
    listCrmSpecItemApi,
    deleteCrmSpecItemApi,
    batchActionCrmSpecItemApi
  } from '@/api/crm/spec-item'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'CrmSpecItem' })
  const router = useRouter()

  interface SpecItemRow {
    id?: string | number
    code?: string
    name?: string
    name_en?: string
    sort?: number
    remark?: string
    [key: string]: any
  }

  const searchForm = ref({ code_cont: undefined, name_cont: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentSpecItem = ref<SpecItemRow | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<SpecItemRow[]>([])

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
      apiFn: listCrmSpecItemApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '项目编号',
          minWidth: 120,
          formatter: (row: unknown) => (row as SpecItemRow).code || '-'
        },
        {
          prop: 'name',
          label: '项目名称',
          minWidth: 140,
          formatter: (row: unknown) => {
            const r = row as SpecItemRow
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.name || '-'
            )
          }
        },
        {
          prop: 'name_en',
          label: '英文名称',
          minWidth: 140,
          formatter: (row: unknown) => (row as SpecItemRow).name_en || '-'
        },
        {
          prop: 'sort',
          label: '排序',
          width: 80,
          formatter: (row: unknown) => (row as SpecItemRow).sort ?? 0
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as SpecItemRow)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as SpecItemRow)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: SpecItemRow) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteSpecItem(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentSpecItem.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: SpecItemRow) => {
    if (row?.id) router.push({ path: `/crm/spec-items/${row.id}` })
  }
  const handleEdit = (row?: SpecItemRow) => {
    currentSpecItem.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteSpecItem = (row: SpecItemRow) => {
    ElMessageBox.confirm(`确定删除指标项目"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCrmSpecItemApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleSpecItemCreated = () => refreshCreate()
  const handleSpecItemUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: SpecItemRow[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的项')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 项吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionCrmSpecItemApi({
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
    exportExcel(columns.value, _data, '指标项目数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
