<template>
  <div class="tab-handovers">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="handleAdd"
        ><ArtSvgIcon icon="ri:add-line" class="mr-1" />新建交接单</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="doc_no" label="交接单号" min-width="130">
        <template #default="{ row }">
          <ElButton link type="primary" @click="goDetail(row)">{{ row.doc_no || '-' }}</ElButton>
        </template>
      </ElTableColumn>
      <ElTableColumn prop="deliver_at" label="要求发货时间" width="120" />
      <ElTableColumn prop="notes" label="说明" min-width="160" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listCrmHandoverApi } from '@/api/crm/handover'

  const props = defineProps<{ contractId?: string | number }>()
  const emit = defineEmits<{ (e: 'add'): void }>()
  const router = useRouter()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (contractId: string | number) => {
    if (!contractId) return
    loading.value = true
    try {
      const res = await listCrmHandoverApi({ 'q[contract_id_eq]': contractId, per_page: 500 })
      const data = (res as any).data || []
      list.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  const goDetail = (row: any) => {
    if (row.id) router.push({ path: `/crm/handovers/${row.id}` })
  }
  const handleAdd = () => emit('add')

  watch(
    () => props.contractId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-handovers .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
