<template>
  <div class="art-full-height">
    <ContractSearch
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
              ><ArtSvgIcon icon="ri:add-line" /> 新建订购合同</ElButton
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
        :data="data as ContractItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <ContractDialog
      v-model="dialogVisible"
      :contract="currentContract"
      :readonly="isViewMode"
      @created="handleContractCreated"
      @updated="handleContractUpdated"
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
  import ContractSearch from './modules/contract-search.vue'
  import ContractDialog from './modules/contract-dialog.vue'
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
    listCrmContractApi,
    deleteCrmContractApi,
    batchActionCrmContractApi
  } from '@/api/crm/contract'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'CrmContract' })
  const router = useRouter()

  interface ContractItem {
    id?: string | number
    code?: string
    sign_at?: string
    client_id?: string | number
    client_name?: string
    deliver_at?: string
    deliver_addr?: string
    [key: string]: any
  }

  const searchForm = ref({ code_cont: undefined, client_id_eq: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentContract = ref<ContractItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<ContractItem[]>([])

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
      apiFn: listCrmContractApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '合同编号',
          minWidth: 130,
          formatter: (row: unknown) => {
            const r = row as ContractItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.code || '-'
            )
          }
        },
        {
          prop: 'client_name',
          label: '客户',
          minWidth: 120,
          formatter: (row: unknown) => (row as ContractItem).client_name || '-'
        },
        {
          prop: 'sign_at',
          label: '签订日期',
          minWidth: 110,
          formatter: (row: unknown) => (row as ContractItem).sign_at || '-'
        },
        {
          prop: 'deliver_at',
          label: '交货时间',
          minWidth: 110,
          formatter: (row: unknown) => (row as ContractItem).deliver_at || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ContractItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ContractItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ContractItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteContract(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentContract.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: ContractItem) => {
    if (row?.id) router.push({ path: `/fm/contracts/${row.id}` })
  }
  const handleEdit = (row?: ContractItem) => {
    currentContract.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteContract = (row: ContractItem) => {
    ElMessageBox.confirm(`确定删除合同"${row.code || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCrmContractApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleContractCreated = () => refreshCreate()
  const handleContractUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: ContractItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的合同')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个合同吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionCrmContractApi({
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
    exportExcel(columns.value, _data, '订购合同数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
