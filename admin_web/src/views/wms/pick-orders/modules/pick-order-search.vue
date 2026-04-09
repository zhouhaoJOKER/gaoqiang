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
  const warehouseOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '单据编号',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入单据编号',
      clearable: true
    },
    {
      label: '状态',
      key: 'status_eq',
      type: 'select',
      placeholder: '请选择状态',
      clearable: true,
      options: [
        { label: '待处理', value: 'pending' },
        { label: '处理中', value: 'processing' },
        { label: '已完成', value: 'completed' },
        { label: '已取消', value: 'cancelled' }
      ]
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

  onMounted(loadWarehouseOptions)
</script>
