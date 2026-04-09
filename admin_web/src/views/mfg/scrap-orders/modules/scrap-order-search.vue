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
  import { listMatProductApi } from '@/api/mat/product'

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
  const productOptions = ref<{ label: string; value: number | string }[]>([])

  const formItems = computed(() => [
    {
      label: '报废单编号',
      key: 'code_cont',
      type: 'input',
      placeholder: '请输入报废单编号',
      clearable: true
    },
    {
      label: '报废类别',
      key: 'scrap_category_eq',
      type: 'input',
      placeholder: '请输入报废类别',
      clearable: true
    },
    {
      label: '产品',
      key: 'product_id_eq',
      type: 'select',
      placeholder: '请选择产品',
      clearable: true,
      filterable: true,
      options: productOptions.value
    }
  ])

  async function loadProductOptions() {
    try {
      const res = await listMatProductApi({ per_page: 300 })
      const list = (res as any).data || []
      productOptions.value = list.map((p: any) => ({
        label: `[${p.code || ''}] ${p.name}`,
        value: p.id
      }))
    } catch (e) {
      console.error('加载产品列表失败', e)
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

  onMounted(loadProductOptions)
</script>
