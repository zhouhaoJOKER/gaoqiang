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
      <ElButton type="primary" @click="emit('add')" v-ripple>
        <ArtSvgIcon icon="ri:add-line" />
        新增
      </ElButton>
    </template>
  </ArtSearchBar>
</template>

<script setup lang="ts">
  import { computed, ref, onMounted } from 'vue'
  import { handleProTableParams } from '@/utils/tool/base'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton } from 'element-plus'
  import { listPurSupplierApi } from '@/api/pur/supplier'

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
  const supplierOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '联系人姓名',
      key: 'name_cont',
      type: 'input',
      placeholder: '请输入联系人姓名',
      clearable: true
    },
    {
      label: '供应商',
      key: 'supplier_id_eq',
      type: 'select',
      placeholder: '请选择供应商',
      clearable: true,
      options: supplierOptions.value
    }
  ])

  async function loadSupplierOptions() {
    try {
      const res = await listPurSupplierApi({ per_page: 500 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      supplierOptions.value = arr.map((s: any) => ({
        label: `[${s.code || ''}] ${s.name}`,
        value: s.id
      }))
    } catch (e) {
      console.error('加载供应商列表失败', e)
    }
  }

  function handleReset() {
    emit('reset')
  }

  async function handleSearch() {
    await searchBarRef.value?.validate()
    emit('search', handleProTableParams(formData.value))
  }

  onMounted(loadSupplierOptions)
</script>
