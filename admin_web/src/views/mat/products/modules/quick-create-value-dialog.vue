<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="500px"
    :close-on-click-modal="false"
    align-center
    class="quick-create-value-dialog"
  >
    <div class="dialog-content">
      <!-- 值名称 -->
      <div class="form-section">
        <div class="form-label">
          <span>值名称</span>
        </div>
        <div class="form-control">
          <ElInput v-model="formData.name" placeholder="请输入值名称" clearable />
        </div>
      </div>

      <!-- 颜色 -->
      <div class="form-section">
        <div class="form-label">
          <span>颜色</span>
        </div>
        <div class="form-control">
          <div class="color-selector">
            <div
              v-for="token in themeColorTokens"
              :key="token"
              class="color-option"
              :class="{ active: formData.color === token }"
              :style="getColorOptionStyle(token)"
              :title="getColorLabel(token)"
              @click="formData.color = token"
            >
              <ArtSvgIcon v-if="formData.color === token" icon="ri:check-line" class="check" />
            </div>
          </div>
        </div>
      </div>

      <!-- 额外价格 -->
      <div class="form-section">
        <div class="form-label">
          <span>默认额外价格</span>
        </div>
        <div class="form-control">
          <ElInput v-model="formData.extra_price" type="number" placeholder="0.00" />
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">{{ isEditMode ? '保存' : '创建' }}</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElDialog, ElButton, ElInput } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { createMatValueApi, updateMatValueApi } from '@/api/mat/attribute'

  interface Props {
    modelValue: boolean
    attributeId?: number
    value?: any // 编辑模式时传入的值
    initialName?: string // 初始名称（用于创建时预填充）
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success', value: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    attributeId: undefined,
    value: undefined,
    initialName: ''
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  // 是否为编辑模式
  const isEditMode = computed(() => !!props.value && !!props.value.id)

  // 对话框标题
  const dialogTitle = computed(() => (isEditMode.value ? '编辑值' : '快速创建值'))

  const formData = ref({
    name: '',
    color: 'primary',
    extra_price: 0
  })

  // 主题色 tokens（完全参照 PropertyConfigDialog）
  const themeColorTokens: string[] = [
    'noset',
    'primary',
    'success',
    'warning',
    'danger',
    'info',
    'primary-light-3',
    'success-light-3',
    'warning-light-3',
    'danger-light-3',
    'info-light-3',
    'primary-light-5',
    'success-light-5',
    'warning-light-5',
    'danger-light-5',
    'info-light-5',
    'primary-light-7',
    'success-light-7',
    'warning-light-7',
    'danger-light-7',
    'info-light-7'
  ]

  // 颜色标签映射（完全参照 PropertyConfigDialog）
  const colorLabelMap: Record<string, string> = {
    noset: '无颜色',
    purple: '紫色',
    cyan: '青色',
    pink: '粉色',
    orange: '橙色',
    teal: '蓝绿',
    indigo: '靛蓝',
    lime: '青柠',
    amber: '琥珀',
    rose: '玫瑰',
    sky: '天蓝',
    violet: '紫罗兰',
    fuchsia: '洋红',
    emerald: '翠绿',
    slate: '石板灰',
    zinc: '锌灰',
    neutral: '中性',
    stone: '石灰'
  }

  // 获取 CSS 变量值
  const cssVar = (name: string): string => {
    if (typeof window === 'undefined') return ''
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
  }

  // 获取颜色标签
  const getColorLabel = (token: string): string => {
    return colorLabelMap[token] || token
  }

  // 获取颜色选项样式（完全参照 PropertyConfigDialog）
  const getColorOptionStyle = (token: string): Record<string, string> => {
    if (token === 'noset') {
      const border = cssVar('--el-border-color') || '#dcdfe6'
      return {
        backgroundColor: cssVar('--el-fill-color-light') || '#f5f7fa',
        borderColor: border,
        backgroundImage: `linear-gradient(135deg, transparent 44%, ${border} 44%, ${border} 56%, transparent 56%)`,
        backgroundRepeat: 'no-repeat'
      }
    }

    const bg = cssVar(`--el-color-${token}`) || `var(--el-color-${token})`
    return {
      backgroundColor: bg,
      borderColor: bg
    }
  }

  // 提交
  const handleSubmit = async (): Promise<void> => {
    if (!formData.value.name.trim()) {
      ElMessage.warning('请输入值名称')
      return
    }

    if (isEditMode.value) {
      // 编辑模式
      if (!props.value?.id) {
        ElMessage.warning('值ID不存在')
        return
      }

      try {
        const res = await updateMatValueApi(String(props.value.id), {
          name: formData.value.name.trim(),
          color: formData.value.color === 'noset' ? '' : formData.value.color,
          extra_price: Number(formData.value.extra_price) || 0
        })

        const value = (res as any).data || { ...props.value, ...formData.value }
        ElMessage.success('保存成功')
        emit('success', value)
        handleCancel()
      } catch (error) {
        console.error('更新值失败:', error)
        ElMessage.error('保存失败')
      }
    } else {
      // 创建模式
      if (!props.attributeId) {
        ElMessage.warning('属性ID不存在')
        return
      }

      try {
        const res = await createMatValueApi({
          attribute_id: props.attributeId,
          name: formData.value.name.trim(),
          color: formData.value.color === 'noset' ? '' : formData.value.color,
          extra_price: Number(formData.value.extra_price) || 0,
          sort: 0
        })

        const value = (res as any).data || {}
        ElMessage.success('创建成功')
        emit('success', value)
        handleCancel()
      } catch (error) {
        console.error('创建值失败:', error)
        ElMessage.error('创建失败')
      }
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 初始化表单
  const initForm = (): void => {
    if (isEditMode.value && props.value) {
      // 编辑模式：使用传入的值
      formData.value = {
        name: props.value.name || '',
        color: props.value.color || 'noset',
        extra_price: props.value.extra_price || 0
      }
    } else {
      // 创建模式：使用初始名称或默认值
      formData.value = {
        name: props.initialName || '',
        color: 'primary',
        extra_price: 0
      }
    }
  }

  // 监听对话框显示和值变化
  watch(
    () => [props.modelValue, props.value],
    ([newVal]) => {
      if (newVal) {
        initForm()
      }
    },
    { immediate: true }
  )
</script>

<style scoped lang="scss">
  .quick-create-value-dialog {
    .dialog-content {
      .form-section {
        margin-bottom: 24px;

        .form-label {
          margin-bottom: 8px;
          font-size: 14px;
          font-weight: 500;
          color: var(--el-text-color-primary);
        }

        .color-selector {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;
        }

        .color-option {
          display: flex;
          align-items: center;
          justify-content: center;
          width: 24px;
          height: 24px;
          cursor: pointer;
          border: 2px solid transparent;
          border-radius: 6px;
          transition: all 0.2s;

          &:hover {
            transform: scale(1.15);
          }

          &.active {
            border-color: var(--el-color-primary);
            box-shadow: 0 0 0 2px var(--el-color-primary-light-7);
          }

          .check {
            font-size: 12px;
            color: #fff;
            text-shadow: 0 1px 2px rgb(0 0 0 / 30%);
          }
        }
      }
    }

    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
