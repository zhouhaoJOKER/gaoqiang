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
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'

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
  const warehouseOptions = ref<{ label: string; value: number | string }[]>([])

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
      label: '仓库',
      key: 'warehouse_id_eq',
      type: 'select',
      placeholder: '请选择仓库',
      clearable: true,
      filterable: true,
      options: warehouseOptions.value
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

  async function loadWarehouseOptions() {
    try {
      const res = await listWmsWarehouseApi({ per_page: 500 })
      const list = (res as any).data || []
      warehouseOptions.value = list.map((w: any) => ({
        label: `[${w.code || ''}] ${w.name}`,
        value: w.id
      }))
    } catch (e) {
      console.error('加载仓库列表失败', e)
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
    loadWarehouseOptions()
  })
</script>
