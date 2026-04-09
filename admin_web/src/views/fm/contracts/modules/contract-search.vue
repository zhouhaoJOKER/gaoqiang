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
  import { listCrmClientApi } from '@/api/crm/client'

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
  const clientOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '合同编号',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入合同编号',
      clearable: true
    },
    {
      label: '客户',
      key: 'client_id_eq',
      type: 'select',
      placeholder: '请选择客户',
      clearable: true,
      options: clientOptions.value
    }
  ])

  async function loadClientOptions() {
    try {
      const res = await listCrmClientApi({ per_page: 500 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.map((c: any) => ({
        label: `[${c.code || ''}] ${c.name}`,
        value: c.id
      }))
    } catch (e) {
      console.error('加载客户列表失败', e)
    }
  }

  function handleReset() {
    emit('reset')
  }
  async function handleSearch() {
    await searchBarRef.value?.validate()
    emit('search', handleProTableParams(formData.value))
  }
  onMounted(loadClientOptions)
</script>
