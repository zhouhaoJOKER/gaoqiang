<!-- 供应商列表页面 -->
<template>
  <div class="art-full-height">
    <SupplierSearch
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
              新建供应商
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
        :data="data as SupplierItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <SupplierDialog
      v-model="dialogVisible"
      :supplier="currentSupplier"
      :readonly="isViewMode"
      @created="handleSupplierCreated"
      @updated="handleSupplierUpdated"
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
  import SupplierSearch from './modules/supplier-search.vue'
  import SupplierDialog from './modules/supplier-dialog.vue'
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
    listPurSupplierApi,
    deletePurSupplierApi,
    batchActionPurSupplierApi
  } from '@/api/pur/supplier'
  import { exportExcel } from '@/utils/tool/toExcel'
  import { useRouter } from 'vue-router'

  defineOptions({ name: 'PurSupplier' })

  interface SupplierItem {
    id?: string | number
    code?: string
    name?: string
    abbr?: string
    qual_notes?: string
    remark?: string
    [key: string]: any
  }

  const searchForm = ref({
    name_cont: undefined,
    code_cont: undefined,
    abbr_cont: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentSupplier = ref<SupplierItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<SupplierItem[]>([])
  const router = useRouter()

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
      apiFn: listPurSupplierApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '供应商名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const r = row as SupplierItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(r)
              },
              r.name || '-'
            )
          }
        },
        {
          prop: 'code',
          label: '供应商编号',
          minWidth: 120,
          formatter: (row: unknown) => (row as SupplierItem).code || '-'
        },
        {
          prop: 'abbr',
          label: '简称',
          minWidth: 100,
          formatter: (row: unknown) => (row as SupplierItem).abbr || '-'
        },
        {
          prop: 'qual_notes',
          label: '资质说明',
          minWidth: 120,
          showOverflowTooltip: true,
          formatter: (row: unknown) => (row as SupplierItem).qual_notes || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as SupplierItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as SupplierItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: SupplierItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteSupplier(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentSupplier.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: SupplierItem) => {
    if (row?.id) router.push({ path: `/pur/suppliers/${row.id}` })
    else {
      currentSupplier.value = row
      isViewMode.value = true
      dialogVisible.value = true
    }
  }

  const handleEdit = (row?: SupplierItem) => {
    currentSupplier.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteSupplier = (row: SupplierItem) => {
    ElMessageBox.confirm(`确定删除供应商"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deletePurSupplierApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleSupplierCreated = () => {
    refreshCreate()
  }

  const handleSupplierUpdated = () => {
    refreshUpdate()
  }

  const handleSelectionChange = (selection: SupplierItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的供应商')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个供应商吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const ids = selectedRows.value.map((r) => r.id).filter(Boolean)
        await batchActionPurSupplierApi({ actions: 'delete', ids })
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
    exportExcel(columns.value, _data, '供应商数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
