<template>
  <div class="tab-quotation-lines">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="$emit('edit')"
        ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑报价单</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="product_name" label="产品名称" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="spec" label="规格" min-width="120" show-overflow-tooltip />
      <ElTableColumn prop="qty" label="数量" width="100" />
      <ElTableColumn prop="unit" label="单位" width="80" />
      <ElTableColumn prop="unit_price" label="含税单价" width="110" />
      <ElTableColumn prop="amount" label="含税金额" width="110" />
      <ElTableColumn prop="remark" label="行备注" min-width="120" show-overflow-tooltip />
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listCrmQuotationLineApi } from '@/api/crm/quotation'

  const props = defineProps<{ quotationId?: string | number }>()
  defineEmits<{ (e: 'edit'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (quotationId: string | number) => {
    if (!quotationId) return
    loading.value = true
    try {
      const res = await listCrmQuotationLineApi({
        'q[quotation_id_eq]': quotationId,
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
    () => props.quotationId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-quotation-lines .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
