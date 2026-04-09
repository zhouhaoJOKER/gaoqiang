<template>
  <div class="art-full-height">
    <RecipeHandoverSearch
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
              ><ArtSvgIcon icon="ri:add-line" /> 新建配方交接单</ElButton
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
        :data="data as RecipeHandoverItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <RecipeHandoverDialog
      v-model="dialogVisible"
      :handover="currentHandover"
      :readonly="isViewMode"
      @created="handleHandoverCreated"
      @updated="handleHandoverUpdated"
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
  import RecipeHandoverSearch from './modules/recipe-handover-search.vue'
  import RecipeHandoverDialog from './modules/recipe-handover-dialog.vue'
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
    listRecipeHandoverApi,
    deleteRecipeHandoverApi,
    batchActionRecipeHandoverApi
  } from '@/api/rms/recipe-handover'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'RmsRecipeHandover' })
  const router = useRouter()

  interface RecipeHandoverItem {
    id?: string | number
    product_id?: string | number
    product_name?: string
    name?: string
    code?: string
    handover_date?: string
    ordering_companies_text?: string
    order_qty?: number | string
    order_qty_unit?: string
    handover_order_id?: string | number
    prepared_id?: string | number
    received_id?: string | number
    general_notes?: string
    [key: string]: any
  }

  const searchForm = ref({ code_cont: undefined, product_id_eq: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentHandover = ref<RecipeHandoverItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<RecipeHandoverItem[]>([])

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
      apiFn: listRecipeHandoverApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '配方单号',
          minWidth: 130,
          formatter: (row: unknown) => {
            const r = row as RecipeHandoverItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.code || '-'
            )
          }
        },
        {
          prop: 'name',
          label: '产品名称',
          minWidth: 140,
          formatter: (row: unknown) => (row as RecipeHandoverItem).name || '-'
        },
        {
          prop: 'handover_date',
          label: '交接日期',
          minWidth: 120,
          formatter: (row: unknown) => (row as RecipeHandoverItem).handover_date || '-'
        },
        {
          prop: 'order_qty',
          label: '订货数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const r = row as RecipeHandoverItem
            const qty = r.order_qty != null ? r.order_qty : '-'
            const unit = r.order_qty_unit ? ` ${r.order_qty_unit}` : ''
            return `${qty}${unit}`
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as RecipeHandoverItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as RecipeHandoverItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: RecipeHandoverItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteHandover(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentHandover.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: RecipeHandoverItem) => {
    if (row?.id) router.push({ path: `/rms/recipe-handovers/${row.id}` })
  }
  const handleEdit = (row?: RecipeHandoverItem) => {
    currentHandover.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteHandover = (row: RecipeHandoverItem) => {
    ElMessageBox.confirm(
      `确定删除配方交接单"${row.code || row.name || '未命名'}"吗？`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(() =>
        deleteRecipeHandoverApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleHandoverCreated = () => refreshCreate()
  const handleHandoverUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: RecipeHandoverItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的配方交接单')
      return
    }
    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个配方交接单吗？`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        await batchActionRecipeHandoverApi({
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
    exportExcel(columns.value, _data, '配方交接单数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
