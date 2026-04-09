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
  import { computed, ref, onMounted } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton } from 'element-plus'
  import { listCrmContractApi } from '@/api/crm/contract'

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
  const contractOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '交接单号',
      key: 'doc_no_cont',
      type: 'input',
      placeholder: '请输入交接单号',
      clearable: true
    },
    {
      label: '合同',
      key: 'contract_id_eq',
      type: 'select',
      placeholder: '请选择合同',
      clearable: true,
      options: contractOptions.value
    }
  ])

  async function loadContractOptions() {
    try {
      const res = await listCrmContractApi({ per_page: 500 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      contractOptions.value = arr.map((c: any) => ({ label: `[${c.code || ''}]`, value: c.id }))
    } catch (e) {
      console.error('加载合同列表失败', e)
    }
  }

  function handleReset() {
    emit('reset')
  }
  async function handleSearch() {
    await searchBarRef.value?.validate()
    emit('search', handleProTableParams(formData.value))
  }
  onMounted(loadContractOptions)
</script>
