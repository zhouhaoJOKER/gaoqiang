<template>
  <ArtSearchBar
    ref="searchBarRef"
    v-model="formData"
    :items="formItems"
    :rules="rules"
    @reset="handleReset"
    @search="handleSearch"
  >
  </ArtSearchBar>
</template>

<script setup lang="ts">
  import { computed, ref, onMounted } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import { listMatItemApi } from '@/api/mat/item'

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
  const itemOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '流水编号',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入流水编号',
      clearable: true
    },
    {
      label: '流水类型',
      key: 'transaction_type_eq',
      type: 'select',
      placeholder: '请选择流水类型',
      clearable: true,
      options: [
        { label: '入库', value: 'in' },
        { label: '出库', value: 'out' },
        { label: '调拨', value: 'transfer' },
        { label: '调整', value: 'adjust' }
      ]
    },
    {
      label: '物品',
      key: 'item_id_eq',
      type: 'select',
      placeholder: '请选择物品',
      clearable: true,
      filterable: true,
      options: itemOptions.value
    }
  ])

  async function loadItemOptions() {
    try {
      const res = await listMatItemApi({ per_page: 300 })
      const list = (res as any).data || []
      itemOptions.value = list.map((i: any) => ({
        label: `[${i.code || ''}] ${i.name}`,
        value: i.id
      }))
    } catch (e) {
      console.error('加载物品列表失败', e)
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

  onMounted(loadItemOptions)
</script>
