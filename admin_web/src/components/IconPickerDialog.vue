<template>
  <ElDialog
    :title="'选择图标'"
    :model-value="visible"
    @update:model-value="handleClose"
    width="800px"
    :close-on-click-modal="false"
  >
    <div class="icon-picker-container">
      <!-- 搜索框 -->
      <ElInput v-model="searchQuery" placeholder="搜索图标名称..." class="mb-4" clearable>
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
      </ElInput>

      <!-- 图标网格 -->
      <div class="icon-grid">
        <div
          v-for="iconName in filteredIcons"
          :key="iconName"
          class="icon-item"
          @click="selectIcon(iconName)"
          :class="{ 'is-selected': selectedIcon === iconName }"
        >
          <ArtSvgIcon :icon="`ri:${iconName}`" class="icon" />
          <span class="icon-name">{{ iconName }}</span>
        </div>
      </div>

      <!-- 已选择图标预览 -->
      <div v-if="selectedIcon" class="selected-preview mt-4 p-3 bg-blue-50 rounded">
        <span class="mr-2">已选择：</span>
        <ArtSvgIcon :icon="`ri:${selectedIcon}`" class="icon mr-2" />
        <span class="font-mono">{{ selectedIcon }}</span>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleConfirm" :disabled="!selectedIcon">确定</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import ArtSvgIcon from './core/base/art-svg-icon/index.vue'
  import { Search } from '@element-plus/icons-vue'
  import riIcons from '@iconify-json/ri/icons.json'

  interface Props {
    visible: boolean
    modelValue?: string
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'confirm', value: string): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false,
    modelValue: ''
  })

  const emit = defineEmits<Emits>()

  // 图标数据
  const allIcons = Object.keys((riIcons as any).icons || {})

  // 搜索查询
  const searchQuery = ref('')

  // 选中的图标
  const selectedIcon = ref('')

  // 过滤后的图标列表
  const filteredIcons = computed(() => {
    const query = searchQuery.value.toLowerCase()
    return allIcons.filter((iconName) => iconName.toLowerCase().includes(query))
  })

  // 监听modelValue变化，更新选中图标
  watch(
    () => props.modelValue,
    (newValue) => {
      if (newValue) {
        // 从完整图标名中提取图标名称，如 "ri:user-line" -> "user-line"
        selectedIcon.value = newValue.replace(/^ri:/, '')
      }
    },
    { immediate: true }
  )

  // 选择图标
  const selectIcon = (iconName: string) => {
    selectedIcon.value = iconName
  }

  // 关闭弹窗
  const handleClose = () => {
    emit('update:visible', false)
  }

  // 确认选择
  const handleConfirm = () => {
    if (selectedIcon.value) {
      emit('confirm', `ri:${selectedIcon.value}`)
      emit('update:visible', false)
    }
  }
</script>

<style scoped>
  .icon-picker-container {
    max-height: 500px;
    overflow-y: auto;
  }

  .icon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 12px;
    max-height: 400px;
    overflow-y: auto;
  }

  .icon-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px;
    text-align: center;
    cursor: pointer;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    transition: all 0.2s;
  }

  .icon-item:hover {
    border-color: #1890ff;
    box-shadow: 0 4px 16px rgb(24 144 255 / 15%);
    transform: translateY(-2px);
  }

  .icon-item.is-selected {
    background-color: #e6f7ff;
    border-color: #1890ff;
    box-shadow: 0 2px 8px rgb(24 144 255 / 20%);
  }

  .icon {
    margin-bottom: 8px;
    font-size: 28px;
    color: #1890ff;
  }

  .icon-name {
    font-size: 12px;
    line-height: 1.3;
    color: #666;
    word-break: break-word;
  }

  .selected-preview {
    display: flex;
    align-items: center;
  }

  .selected-preview .icon {
    margin-bottom: 0;
    font-size: 20px;
  }
</style>
