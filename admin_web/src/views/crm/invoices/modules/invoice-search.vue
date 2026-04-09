<template>
  <ArtSearchBar
    ref="searchBarRef"
    v-model="formData"
    :items="formItems"
    :rules="rules"
    @reset="handleReset"
    @search="handleSearch"
  >
    <template #action-extra>
      <ElButton type="primary" @click="emit('add')" v-ripple
        ><ArtSvgIcon icon="ri:add-line" /> 新增</ElButton
      >
    </template>
  </ArtSearchBar>
</template>

<script setup lang="ts">
  import { computed, ref } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton } from 'element-plus'

  interface Props {
    modelValue: Record<string, any>
  }
  interface Emits {
    (e: 'update:modelValue', value: Record<string, any>): void
    (e: 'search', params: Record<string, any>): void
    (e: 'reset'): void
    (e: 'add'): void
  }
  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const searchBarRef = ref()
  const formData = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const rules = {}
  const formItems = computed(() => [
    {
      label: '开票抬头',
      key: 'title_cont',
      type: 'input',
      placeholder: '请输入开票抬头',
      clearable: true
    },
    { label: '税号', key: 'tax_no_cont', type: 'input', placeholder: '请输入税号', clearable: true }
  ])

  function handleReset() {
    emit('reset')
  }
  async function handleSearch() {
    await searchBarRef.value?.validate()
    emit('search', handleProTableParams(formData.value))
  }
</script>
