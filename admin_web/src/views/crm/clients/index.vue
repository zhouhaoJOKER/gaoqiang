<!-- 客户列表页面 -->
<template>
  <div class="art-full-height">
    <ClientSearch
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
              新建客户
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
        :data="data as ClientItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <ClientDialog
      v-model="dialogVisible"
      :client="currentClient"
      :readonly="isViewMode"
      @created="handleClientCreated"
      @updated="handleClientUpdated"
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
  import ClientSearch from './modules/client-search.vue'
  import ClientDialog from './modules/client-dialog.vue'
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
  import { listCrmClientApi, deleteCrmClientApi, batchActionCrmClientApi } from '@/api/crm/client'
  import { exportExcel } from '@/utils/tool/toExcel'
  import { useRouter } from 'vue-router'

  defineOptions({ name: 'CrmClient' })

  interface ClientItem {
    id?: string | number
    parent_id?: string | number
    parent_name?: string
    code?: string
    name?: string
    abbr?: string
    settlement_id?: string | number
    payment_terms?: string
    invoice_type_id?: string | number
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
  const currentClient = ref<ClientItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<ClientItem[]>([])
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
      apiFn: listCrmClientApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '客户名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const r = row as ClientItem
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
          label: '客户编号',
          minWidth: 120,
          formatter: (row: unknown) => (row as ClientItem).code || '-'
        },
        {
          prop: 'abbr',
          label: '简称',
          minWidth: 100,
          formatter: (row: unknown) => (row as ClientItem).abbr || '-'
        },
        {
          prop: 'parent_name',
          label: '父级客户',
          minWidth: 120,
          formatter: (row: unknown) => (row as ClientItem).parent_name || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ClientItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ClientItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ClientItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteClient(row)
        break
    }
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }

  const handleCreate = () => {
    currentClient.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: ClientItem) => {
    if (row?.id) router.push({ path: `/crm/clients/${row.id}` })
    else {
      currentClient.value = row
      isViewMode.value = true
      dialogVisible.value = true
    }
  }

  const handleEdit = (row?: ClientItem) => {
    currentClient.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteClient = (row: ClientItem) => {
    ElMessageBox.confirm(`确定删除客户"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteCrmClientApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleClientCreated = () => {
    refreshCreate()
  }

  const handleClientUpdated = () => {
    refreshUpdate()
  }

  const handleSelectionChange = (selection: ClientItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的客户')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个客户吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        const ids = selectedRows.value.map((r) => r.id).filter(Boolean)
        await batchActionCrmClientApi({ actions: 'delete', ids })
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
    exportExcel(columns.value, _data, '客户数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
