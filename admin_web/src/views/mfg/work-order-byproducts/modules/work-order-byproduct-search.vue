<template>
  <ArtSearchBar
    ref="searchBarRef"
    v-model="formData"
    :items="formItems"
    :rules="rules"
    @reset="handleReset"
    @search="handleSearch"
  />
</template>

<script setup lang="ts">
  import { computed, ref, onMounted } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import { listMfgWorkOrderApi } from '@/api/mfg/work-order'
  import { listMatProductApi } from '@/api/mat/product'

  interface Props {
    modelValue: Record<string, any>
  }
  interface Emits {
    (e: 'update:modelValue', value: Record<string, any>): void
    (e: 'search', params: Record<string, any>): void
    (e: 'reset'): void
  }
  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const searchBarRef = ref()
  const formData = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const rules = {}
  const workOrderOptions = ref<{ label: string; value: number | string }[]>([])
  const productOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '工单',
      key: 'work_order_id_eq',
      type: 'select',
      placeholder: '请选择工单',
      clearable: true,
      filterable: true,
      options: workOrderOptions.value
    },
    {
      label: '产品',
      key: 'product_id_eq',
      type: 'select',
      placeholder: '请选择产品',
      clearable: true,
      filterable: true,
      options: productOptions.value
    }
  ])

  async function loadWorkOrderOptions() {
    try {
      const res = await listMfgWorkOrderApi({ per_page: 300 })
      const list = (res as any).data || []
      workOrderOptions.value = list.map((wo: any) => ({
        label: `[${wo.code || ''}] ${wo.product_name || ''}`,
        value: wo.id
      }))
    } catch (e) {
      console.error('加载工单列表失败', e)
    }
  }

  async function loadProductOptions() {
    try {
      const res = await listMatProductApi({ per_page: 300 })
      const list = (res as any).data || []
      productOptions.value = list.map((p: any) => ({
        label: `[${p.code || ''}] ${p.name}`,
        value: p.id
      }))
    } catch (e) {
      console.error('加载产品列表失败', e)
    }
  }

  function handleReset() {
    emit('reset')
  }

  async function handleSearch() {
    await searchBarRef.value.validate()
    const newParams = handleProTableParams(formData.value)
    emit('search', newParams)
  }

  onMounted(() => {
    loadWorkOrderOptions()
    loadProductOptions()
  })
</script>
