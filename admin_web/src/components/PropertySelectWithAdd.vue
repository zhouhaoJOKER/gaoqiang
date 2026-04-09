<template>
  <div class="property-select-with-add">
    <ElSelect
      v-model="selectedValue"
      :placeholder="placeholder"
      :size="size"
      clearable
      filterable
      remote
      :remote-method="searchOptions"
      :loading="searchLoading"
      style="width: 100%"
      :disabled="disabled"
      @change="handleChange"
    >
      <ElOption v-for="item in options" :key="item.id" :label="item.name" :value="item.id" />
      <ElOption
        v-if="!disabled"
        :value="''"
        disabled
        style="border-top: 1px solid var(--el-border-color-lighter)"
      >
        <div class="property-option-footer">
          <ElButton text type="primary" size="small" @click.stop="openConfig">
            创建或编辑...
          </ElButton>
        </div>
      </ElOption>
    </ElSelect>

    <PropertyConfigDialog
      v-model="configVisible"
      :sign="sign"
      :title="configTitle"
      @updated="loadOptions"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElSelect, ElOption, ElButton } from 'element-plus'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import { listPropertyApi } from '@/api/property'

  interface Props {
    modelValue?: string | number | null
    sign: string
    placeholder?: string
    configTitle?: string
    disabled?: boolean
    size?: 'default' | 'large' | 'small'
    /** 变化时重新加载选项（用于外部创建新项后刷新） */
    refreshTrigger?: string | number
    /** 仅一级（parent_id 为空），用于产品大类 */
    rootOnly?: boolean
    /** 仅某父级下的子项（规格），需传大类 id */
    parentIdEq?: string | number | null
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: null,
    placeholder: '请选择',
    configTitle: '',
    disabled: false,
    size: 'default',
    rootOnly: false,
    parentIdEq: null
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', value: string | number | null): void
    (e: 'change', value: string | number | null): void
  }>()

  const options = ref<Array<{ id: string | number; name: string; [key: string]: any }>>([])
  const searchLoading = ref(false)
  const configVisible = ref(false)

  const selectedValue = computed({
    get: () => props.modelValue ?? null,
    set: (val) => {
      if (val !== '' && val !== '__add__') {
        emit('update:modelValue', val)
        emit('change', val)
      }
    }
  })

  const searchOptions = async (query: string): Promise<void> => {
    searchLoading.value = true
    try {
      const params: Record<string, any> = {
        'q[sign_eq]': props.sign,
        'q[name_or_py_cont]': query || '',
        per_page: 100
      }
      if (props.rootOnly) {
        params['q[parent_id_null]'] = true
      }
      if (props.parentIdEq != null && props.parentIdEq !== '') {
        params['q[parent_id_eq]'] = props.parentIdEq
      }
      const res = await listPropertyApi(params)
      const data = (res as any).data || []
      options.value = Array.isArray(data) ? data.filter((item: any) => item && item.id != null) : []
    } catch (error) {
      console.error('加载属性失败:', error)
      ElMessage.error('加载属性失败')
      options.value = []
    } finally {
      searchLoading.value = false
    }
  }

  const loadOptions = async (): Promise<void> => {
    await searchOptions('')
  }

  const openConfig = (): void => {
    configVisible.value = true
  }

  const handleChange = (val: string | number | null): void => {
    if (val !== '' && val !== '__add__') {
      emit('update:modelValue', val)
      emit('change', val)
    }
  }

  watch(
    () => props.sign,
    () => {
      loadOptions()
    }
  )

  watch(
    () => [props.rootOnly, props.parentIdEq],
    () => {
      loadOptions()
    }
  )

  watch(
    () => props.refreshTrigger,
    () => {
      loadOptions()
    }
  )

  onMounted(() => {
    loadOptions()
  })
</script>

<style scoped>
  .property-select-with-add {
    width: 100%;
  }

  .property-option-footer {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 4px 0;
  }
</style>
