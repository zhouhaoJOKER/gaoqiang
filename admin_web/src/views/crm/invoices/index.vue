<template>
  <div class="art-full-height">
    <InvoiceSearch
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
              ><ArtSvgIcon icon="ri:add-line" /> 新建开票信息</ElButton
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
        :data="data as InvoiceItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <InvoiceDialog
      v-model="dialogVisible"
      :invoice="currentInvoice"
      :readonly="isViewMode"
      @created="handleInvoiceCreated"
      @updated="handleInvoiceUpdated"
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
  import InvoiceSearch from './modules/invoice-search.vue'
  import InvoiceDialog from './modules/invoice-dialog.vue'
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
    listCrmInvoiceApi,
    deleteCrmInvoiceApi,
    batchActionCrmInvoiceApi
  } from '@/api/crm/invoice'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'CrmInvoice' })
  const router = useRouter()

  interface InvoiceItem {
    id?: string | number
    billable_type?: string
    billable_id?: string | number
    title?: string
    tax_no?: string
    address?: string
    phone?: string
    bank_name?: string
    bank_account?: string
    invoice_type_id?: string | number
    is_default?: boolean
    remark?: string
    [key: string]: any
  }

  const searchForm = ref({ title_cont: undefined, tax_no_cont: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentInvoice = ref<InvoiceItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<InvoiceItem[]>([])

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
      apiFn: listCrmInvoiceApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'title',
          label: '开票抬头',
          minWidth: 160,
          formatter: (row: unknown) => {
            const r = row as InvoiceItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.title || '-'
            )
          }
        },
        {
          prop: 'tax_no',
          label: '税号',
          minWidth: 160,
          formatter: (row: unknown) => (row as InvoiceItem).tax_no || '-'
        },
        {
          prop: 'billable_type',
          label: '关联类型',
          width: 100,
          formatter: (row: unknown) =>
            (row as InvoiceItem).billable_type === 'Crm::Client' ? '客户' : '供应商'
        },
        {
          prop: 'is_default',
          label: '默认',
          width: 70,
          formatter: (row: unknown) => ((row as InvoiceItem).is_default ? '是' : '否')
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as InvoiceItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as InvoiceItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: InvoiceItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteInvoice(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentInvoice.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: InvoiceItem) => {
    if (row?.id) router.push({ path: `/crm/invoices/${row.id}` })
  }
  const handleEdit = (row?: InvoiceItem) => {
    currentInvoice.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteInvoice = (row: InvoiceItem) => {
    ElMessageBox.confirm(`确定删除开票信息"${row.title || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCrmInvoiceApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleInvoiceCreated = () => refreshCreate()
  const handleInvoiceUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: InvoiceItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的开票信息')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 条吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionCrmInvoiceApi({
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
    exportExcel(columns.value, _data, '开票信息数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
