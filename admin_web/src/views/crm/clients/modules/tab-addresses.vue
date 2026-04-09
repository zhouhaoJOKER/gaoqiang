<template>
  <div class="tab-addresses">
    <div class="tab-toolbar">
      <ElInput
        v-model="searchKeyword"
        placeholder="收件人/电话/地址"
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
        添加收货地址
      </ElButton>
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="addr_kind" label="地址类型" min-width="100" />
      <ElTableColumn prop="contact" label="收件人" min-width="100" />
      <ElTableColumn prop="phone" label="电话" min-width="120" />
      <ElTableColumn prop="addr" label="地址" min-width="200" show-overflow-tooltip />
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
    <AddressDialog
      v-model="dialogVisible"
      :address="currentAddress"
      :fixed-client-id="clientId"
      :readonly="false"
      @created="handleCreated"
      @updated="handleUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { Search } from '@element-plus/icons-vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElInput, ElButton, ElTable, ElTableColumn, ElPagination } from 'element-plus'
  import { listCrmAddressApi, deleteCrmAddressApi } from '@/api/crm/address'
  import AddressDialog from '@/views/crm/addresses/modules/address-dialog.vue'

  interface Props {
    clientId?: string | number
    clientData?: Record<string, any>
  }
  const props = defineProps<Props>()
  const emit = defineEmits<{ (e: 'refresh'): void }>()

  const searchKeyword = ref('')
  const loading = ref(false)
  const list = ref<any[]>([])
  const page = ref(1)
  const pageSize = ref(20)
  const total = ref(0)
  const dialogVisible = ref(false)
  const currentAddress = ref<any>(undefined)

  const fetchList = async () => {
    if (!props.clientId) return
    loading.value = true
    try {
      const params: any = {
        page: page.value,
        per_page: pageSize.value,
        'q[client_id_eq]': props.clientId
      }
      if (searchKeyword.value) params['q[contact_or_phone_or_addr_cont]'] = searchKeyword.value
      const res = await listCrmAddressApi(params)
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
    currentAddress.value = undefined
    dialogVisible.value = true
  }
  const handleEdit = (row: any) => {
    currentAddress.value = row
    dialogVisible.value = true
  }
  const handleDelete = (row: any) => {
    ElMessageBox.confirm(`确定删除该地址吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => deleteCrmAddressApi(Number(row.id)))
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
  .tab-addresses .tab-toolbar {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 16px;
  }
</style>
