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
  import { computed, ref } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'

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

  const searchBarRef = ref<any>()
  const formData = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const rules = {}

  const formItems = computed(() => [
    {
      label: 'BOM明细行',
      key: 'bom_line_id_eq',
      type: 'input',
      placeholder: '请输入BOM明细行ID',
      clearable: true
    },
    {
      label: '损耗模式',
      key: 'loss_mode_eq',
      type: 'select',
      placeholder: '请选择损耗模式',
      clearable: true,
      options: [
        { label: '百分比', value: 'percent' },
        { label: '固定值', value: 'fixed' }
      ]
    }
  ])

  function handleReset() {
    emit('reset')
  }

  async function handleSearch() {
    await searchBarRef.value.validate()
    const newParams = handleProTableParams(formData.value)
    emit('search', newParams)
  }
</script>
