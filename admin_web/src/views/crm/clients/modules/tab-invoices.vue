<template>
  <div class="tab-invoices">
    <div class="tab-toolbar">
      <ElInput
        v-model="searchKeyword"
        placeholder="开票抬头/税号"
        clearable
        style="width: 260px"
        @keyup.enter="fetchList"
      >
        <template #append>
          <ElButton :icon="Search" @click="fetchList" />
        </template>
      </ElInput>
      <ElButton type="primary" @click="handleAdd">
        <ArtSvgIcon icon="ri:add-line" class="mr-1" />
        添加开票信息
      </ElButton>
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="title" label="开票抬头" min-width="160" show-overflow-tooltip />
      <ElTableColumn prop="tax_no" label="税号" min-width="160" />
      <ElTableColumn prop="address" label="地址" min-width="180" show-overflow-tooltip />
      <ElTableColumn prop="is_default" label="默认" width="70">
        <template #default="{ row }">{{ row.is_default ? '是' : '否' }}</template>
      </ElTableColumn>
      <ElTableColumn label="操作" width="120" fixed="right">
        <template #default="{ row }">
          <ElButton link type="primary" size="small" @click="handleEdit(row)">编辑</ElButton>
          <ElButton link type="danger" size="small" @click="handleDelete(row)">删除</ElButton>
        </template>
      </ElTableColumn>
    </ElTable>
    <ElPagination
      v-model:current-page="page"
      v-model:page-size="pageSize"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next"
      class="mt-3"
      @current-change="fetchList"
      @size-change="fetchList"
    />
    <InvoiceDialog
      v-model="dialogVisible"
      :invoice="currentInvoice"
      :initial-billable="initialBillable"
      :readonly="false"
      @created="handleCreated"
      @updated="handleUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { Search } from '@element-plus/icons-vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElInput, ElButton, ElTable, ElTableColumn, ElPagination } from 'element-plus'
  import { listCrmInvoiceApi, deleteCrmInvoiceApi } from '@/api/crm/invoice'
  import InvoiceDialog from '@/views/crm/invoices/modules/invoice-dialog.vue'

  interface Props {
    clientId?: string | number
    clientData?: Record<string, any>
  }
  const props = defineProps<Props>()
  const emit = defineEmits<{ (e: 'refresh'): void }>()

  const initialBillable = computed(() =>
    props.clientId != null
      ? { billable_type: 'Crm::Client' as const, billable_id: props.clientId }
      : undefined
  )

  const searchKeyword = ref('')
  const loading = ref(false)
  const list = ref<any[]>([])
  const page = ref(1)
  const pageSize = ref(20)
  const total = ref(0)
  const dialogVisible = ref(false)
  const currentInvoice = ref<any>(undefined)

  const fetchList = async () => {
    if (!props.clientId) return
    loading.value = true
    try {
      const params: any = {
        page: page.value,
        per_page: pageSize.value,
        'q[billable_type_eq]': 'Crm::Client',
        'q[billable_id_eq]': props.clientId
      }
      if (searchKeyword.value) params['q[title_or_tax_no_cont]'] = searchKeyword.value
      const res = await listCrmInvoiceApi(params)
      const data = (res as any).data
      list.value = Array.isArray(data) ? data : (data?.list ?? data?.data ?? [])
      total.value = (res as any).total ?? (res as any).meta?.total ?? list.value.length
    } catch {
      list.value = []
      total.value = 0
    } finally {
      loading.value = false
    }
  }

  const handleAdd = () => {
    currentInvoice.value = undefined
    dialogVisible.value = true
  }
  const handleEdit = (row: any) => {
    currentInvoice.value = row
    dialogVisible.value = true
  }
  const handleDelete = (row: any) => {
    ElMessageBox.confirm(`确定删除开票信息"${row.title || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => deleteCrmInvoiceApi(Number(row.id)))
      .then(() => {
        ElMessage.success('删除成功')
        fetchList()
        emit('refresh')
      })
      .catch(() => ElMessage.info('已取消'))
  }

  const handleCreated = () => {
    fetchList()
    emit('refresh')
  }
  const handleUpdated = () => {
    fetchList()
    emit('refresh')
  }

  watch(
    () => props.clientId,
    (id) => {
      if (id) {
        page.value = 1
        fetchList()
      }
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-invoices .tab-toolbar {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 16px;
  }
</style>
