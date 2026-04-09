<template>
  <ArtSearchBar
    v-model="localValue"
    :items="formItems"
    :showExpand="false"
    @reset="handleReset"
    @search="handleSearch"
  />
</template>

<script setup lang="ts">
  import { computed } from 'vue'

  interface SearchForm {
    name?: string
    code?: string
    is_active?: boolean | ''
  }

  const props = defineProps<{
    modelValue: SearchForm
  }>()

  const emit = defineEmits<{
    (e: 'update:modelValue', value: SearchForm): void
    (e: 'search', value: SearchForm): void
    (e: 'reset'): void
  }>()

  const localValue = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const formItems = [
    {
      label: '名称',
      key: 'name',
      type: 'input',
      props: { clearable: true, placeholder: '请输入产品名称' }
    },
    {
      label: '编码',
      key: 'code',
      type: 'input',
      props: { clearable: true, placeholder: '请输入产品编码' }
    },
    {
      label: '状态',
      key: 'is_active',
      type: 'select',
      props: {
        clearable: true,
        options: [
          { label: '启用', value: true },
          { label: '停用', value: false }
        ]
      }
    }
  ]

  const handleSearch = () => {
    emit('search', localValue.value)
  }

  const handleReset = () => {
    emit('reset')
  }
</script>
