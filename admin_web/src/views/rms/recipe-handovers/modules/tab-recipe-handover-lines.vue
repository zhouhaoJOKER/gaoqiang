<template>
  <div class="tab-recipe-handover-lines">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="$emit('edit')"
        ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑配方交接单</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="name" label="原辅料品名" min-width="180" show-overflow-tooltip />
      <ElTableColumn
        prop="feeding_rate"
        label="投料比例(g/L)"
        min-width="140"
        show-overflow-tooltip
      >
        <template #default="{ row }">
          {{ row.feeding_rate != null ? row.feeding_rate : '-' }}
        </template>
      </ElTableColumn>
      <ElTableColumn prop="remark" label="备注" min-width="140" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listRecipeHandoverLineApi } from '@/api/rms/recipe-handover'

  const props = defineProps<{ handoverId?: string | number }>()
  defineEmits<{ (e: 'edit'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (handoverId: string | number) => {
    if (!handoverId) return
    loading.value = true
    try {
      const res = await listRecipeHandoverLineApi({
        'q[handover_id_eq]': handoverId,
        per_page: 500
      })
      const linesData = (res as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      list.value = arr.map((line: any) => ({
        ...line,
        name: line.name || line.product_name || '-'
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
  .tab-recipe-handover-lines .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
