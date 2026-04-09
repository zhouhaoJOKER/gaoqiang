<template>
  <div class="tab-raw-inspection-lines">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="$emit('edit')"
        ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑原料检验</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn
        prop="content_percent"
        label="含量（%）"
        min-width="120"
        show-overflow-tooltip
      />
      <ElTableColumn prop="m_value" label="样品 m" min-width="120" show-overflow-tooltip />
      <ElTableColumn prop="a_r_value" label="样品 A(r)" min-width="120" show-overflow-tooltip />
      <ElTableColumn prop="x_percent" label="样品 X（%）" min-width="120" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listIqcRawLineApi } from '@/api/iqc/raw'

  const props = defineProps<{ rawId?: string | number }>()
  defineEmits<{ (e: 'edit'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (rawId: string | number) => {
    if (!rawId) return
    loading.value = true
    try {
      const res = await listIqcRawLineApi({
        'q[raw_id_eq]': rawId,
        per_page: 500
      })
      const linesData = (res as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      list.value = arr
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  watch(
    () => props.rawId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-raw-inspection-lines .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
