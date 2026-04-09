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
  import { listMatItemApi } from '@/api/mat/item'
  import { listWmsLocationApi } from '@/api/wms/location'

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
  const locationOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '物品',
      key: 'item_id_eq',
      type: 'select',
      placeholder: '请选择物品',
      clearable: true,
      filterable: true,
      options: itemOptions.value
    },
    {
      label: '货位',
      key: 'location_id_eq',
      type: 'select',
      placeholder: '请选择货位',
      clearable: true,
      filterable: true,
      options: locationOptions.value
    },
    {
      label: '订单类型',
      key: 'order_type_eq',
      type: 'input',
      placeholder: '请输入订单类型',
      clearable: true
    },
    {
      label: '状态',
      key: 'status_eq',
      type: 'select',
      placeholder: '请选择状态',
      clearable: true,
      options: [
        { label: '有效', value: 'active' },
        { label: '已过期', value: 'expired' },
        { label: '已释放', value: 'released' }
      ]
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

  async function loadLocationOptions() {
    try {
      const res = await listWmsLocationApi({ per_page: 500 })
      const list = (res as any).data || []
      locationOptions.value = list.map((l: any) => ({
        label: `[${l.code || ''}] ${l.name}`,
        value: l.id
      }))
    } catch (e) {
      console.error('加载货位列表失败', e)
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
    loadItemOptions()
    loadLocationOptions()
  })
</script>
