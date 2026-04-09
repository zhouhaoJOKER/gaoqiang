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
  import { listCompanyApi } from '@/api/company'

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
  const companyOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '仓库名称',
      key: 'name_cont',
      type: 'input',
      placeholder: '请输入仓库名称',
      clearable: true
    },
    {
      label: '仓库编码',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入仓库编码',
      clearable: true
    },
    {
      label: '公司',
      key: 'company_id_eq',
      type: 'select',
      placeholder: '请选择公司',
      clearable: true,
      options: companyOptions.value
    }
  ])

  async function loadCompanyOptions() {
    try {
      const res = await listCompanyApi({ per_page: 500 })
      const list = (res as any).data || []
      companyOptions.value = list.map((c: any) => ({ label: c.name, value: c.id }))
    } catch (e) {
      console.error('加载公司列表失败', e)
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

  onMounted(loadCompanyOptions)
</script>
