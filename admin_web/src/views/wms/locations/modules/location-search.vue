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
  import { computed, ref, onMounted, watch } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'
  import { listWmsAreaApi } from '@/api/wms/area'

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
  const warehouseOptions = ref<{ label: string; value: number | string }[]>([])
  const areaOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '货位名称',
      key: 'name_cont',
      type: 'input',
      placeholder: '请输入货位名称',
      clearable: true
    },
    {
      label: '货位编码',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入货位编码',
      clearable: true
    },
    {
      label: '仓库',
      key: 'warehouse_id_eq',
      type: 'select',
      placeholder: '请选择仓库',
      clearable: true,
      filterable: true,
      options: warehouseOptions.value
    },
    {
      label: '库区',
      key: 'area_id_eq',
      type: 'select',
      placeholder: '请选择库区',
      clearable: true,
      filterable: true,
      options: areaOptions.value
    }
  ])

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

  async function loadAreaOptions() {
    const wid = formData.value?.warehouse_id_eq
    if (!wid) {
      areaOptions.value = []
      return
    }
    try {
      const res = await listWmsAreaApi({ 'q[warehouse_id_eq]': wid, per_page: 500 })
      const list = (res as any).data || []
      areaOptions.value = list.map((a: any) => ({
        label: `[${a.code || ''}] ${a.name}`,
        value: a.id
      }))
    } catch (e) {
      console.error('加载库区列表失败', e)
    }
  }

  watch(
    () => formData.value?.warehouse_id_eq,
    (val, prev) => {
      if (val !== prev) {
        emit('update:modelValue', { ...formData.value, area_id_eq: undefined })
        if (!val) {
          areaOptions.value = []
        } else {
          loadAreaOptions()
        }
      }
    }
  )

  function handleReset() {
    areaOptions.value = []
    emit('reset')
  }

  async function handleSearch() {
    await searchBarRef.value.validate()
    const newParams = handleProTableParams(formData.value)
    emit('search', newParams)
  }

  onMounted(() => {
    loadWarehouseOptions()
    const wid = formData.value?.warehouse_id_eq
    if (wid) loadAreaOptions()
  })
</script>
