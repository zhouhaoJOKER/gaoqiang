<template>
  <div class="tab-handover-lines">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="$emit('edit')"
        ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑交接单</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="spec_item_name" label="指标项目" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="contract_req" label="合同要求" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="internal_req" label="内控要求" min-width="140" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listCrmHandoverLineApi } from '@/api/crm/handover'
  import { listCrmSpecItemApi } from '@/api/crm/spec-item'

  const props = defineProps<{ handoverId?: string | number }>()
  defineEmits<{ (e: 'edit'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])
  const specItemMap = ref<Record<string, string>>({})

  const fetchList = async (handoverId: string | number) => {
    if (!handoverId) return
    loading.value = true
    try {
      const [linesRes, specRes] = await Promise.all([
        listCrmHandoverLineApi({ 'q[handover_id_eq]': handoverId, per_page: 500 }),
        listCrmSpecItemApi({ per_page: 500 })
      ])
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      const specList = (specRes as any).data || []
      const specArr = Array.isArray(specList) ? specList : specList.list || specList.data || []
      const map: Record<string, string> = {}
      specArr.forEach((s: any) => {
        if (s?.id != null) map[s.id] = s.name || ''
      })
      specItemMap.value = map
      list.value = arr.map((line: any) => ({
        ...line,
        spec_item_name: map[line.spec_item_id] || '-'
      }))
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  watch(
    () => props.handoverId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-handover-lines .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
