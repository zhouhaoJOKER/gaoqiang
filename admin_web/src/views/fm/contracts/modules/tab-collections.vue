<template>
  <div class="tab-collections">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="$emit('edit')"
        ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑合同</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="name" label="产品名称" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="unit_name" label="单位" width="80" />
      <ElTableColumn prop="qty" label="数量" width="100" />
      <ElTableColumn prop="price" label="单价" width="100" />
      <ElTableColumn prop="amount_excl_tax" label="不含税金额" width="110" />
      <ElTableColumn prop="tax" label="税额" width="100" />
      <ElTableColumn prop="amount" label="总金额" width="110" />
      <ElTableColumn prop="remark" label="备注" min-width="120" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listCrmCollectionApi } from '@/api/crm/contract'

  const props = defineProps<{ contractId?: string | number }>()
  defineEmits<{ (e: 'edit'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (contractId: string | number) => {
    if (!contractId) return
    loading.value = true
    try {
      const res = await listCrmCollectionApi({ 'q[contract_id_eq]': contractId, per_page: 500 })
      const data = (res as any).data || []
      list.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  watch(
    () => props.contractId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-collections .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
