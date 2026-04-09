<template>
  <div class="property-select">
    <ElSelect
      v-model="selectedValue"
      :placeholder="placeholder"
      clearable
      filterable
      class="property-select-input"
    >
      <ElOption v-for="item in options" :key="item.id" :label="item.name" :value="item.id" />
    </ElSelect>
    <ElButton text class="config-btn" @click="openConfig">
      <ArtSvgIcon icon="ri:settings-3-line" class="mr-1" />
      配置
    </ElButton>

    <PropertyConfigDialog v-model="configVisible" :sign="sign" @updated="loadOptions" />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import { listPropertyApi } from '@/api/property'

  interface Props {
    modelValue?: string | number | null
    sign: string
    placeholder?: string
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: null,
    placeholder: '请选择'
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', value: string | number | null): void
    (e: 'change', value: string | number | null): void
  }>()

  const options = ref<Array<{ id: string | number; name: string }>>([])
  const configVisible = ref(false)

  const selectedValue = computed({
    get: () => props.modelValue ?? null,
    set: (val) => {
      emit('update:modelValue', val)
      emit('change', val)
    }
  })

  const loadOptions = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': props.sign })
      const data = (res as any).data || []
      options.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载属性失败:', error)
      ElMessage.error('加载属性失败')
      options.value = []
    }
  }

  const openConfig = (): void => {
    configVisible.value = true
  }

  watch(
    () => props.sign,
    () => {
      loadOptions()
    }
  )

  onMounted(() => {
    loadOptions()
  })
</script>

<style scoped>
  .property-select {
    display: flex;
    gap: 8px;
    align-items: center;
    width: 100%;
  }

  .property-select-input {
    flex: 1;
  }

  .config-btn {
    padding: 0 8px;
  }
</style>
