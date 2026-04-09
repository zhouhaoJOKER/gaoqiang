<template>
  <div class="tab-recipe-handover-contracts">
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="contract_code" label="合同编号" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="qty" label="数量" width="100" />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import { ElTable, ElTableColumn } from 'element-plus'
  import { listRecipeHandoverContractApi } from '@/api/rms/recipe-handover'

  const props = defineProps<{ handoverId?: string | number }>()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (handoverId: string | number) => {
    if (!handoverId) return
    loading.value = true
    try {
      const res = await listRecipeHandoverContractApi({
        'q[recipe_handover_id_eq]': handoverId,
        per_page: 500
      })
      const data = (res as any).data || []
      list.value = Array.isArray(data) ? data : data.list || data.data || []
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
  .tab-recipe-handover-contracts {
    min-height: 100px;
  }
</style>
