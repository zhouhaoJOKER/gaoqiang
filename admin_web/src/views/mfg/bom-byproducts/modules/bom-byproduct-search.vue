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
  import { listMfgBomApi } from '@/api/mfg/bom'
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
  const bomOptions = ref<{ label: string; value: number | string }[]>([])
  const productOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: 'BOM',
      key: 'bom_id_eq',
      type: 'select',
      placeholder: '请选择BOM',
      clearable: true,
      filterable: true,
      options: bomOptions.value
    },
    {
      label: '产品',
      key: 'product_id_eq',
      type: 'select',
      placeholder: '请选择产品',
      clearable: true,
      filterable: true,
      options: productOptions.value
    },
    {
      label: '产出类别',
      key: 'output_category_eq',
      type: 'select',
      placeholder: '请选择产出类别',
      clearable: true,
      options: [
        { label: '废料', value: 'scrap' },
        { label: '副产品', value: 'byproduct' }
      ]
    }
  ])

  async function loadBomOptions() {
    try {
      const res = await listMfgBomApi({ per_page: 300 })
      const list = (res as any).data || []
      bomOptions.value = list.map((bom: any) => ({
        label: `[${bom.code || ''}] ${bom.product_name || ''}`,
        value: bom.id
      }))
    } catch (e) {
      console.error('加载BOM列表失败', e)
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
    loadBomOptions()
    loadProductOptions()
  })
</script>
