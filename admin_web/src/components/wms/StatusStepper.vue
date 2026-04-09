<template>
  <div class="status-header">
    <!-- 左侧动作按钮 -->
    <div v-if="!isFinalStatus" class="status-actions">
      <ElButton
        v-if="props.id && (status === 'pending' || status === 'draft')"
        class="btn-confirm"
        size="small"
        @click="handleUpdateStatus('confirmed', '确认该单据？')"
      >
        确认
      </ElButton>
      <ElButton
        v-if="props.id && (status === 'confirmed' || status === 'in_progress')"
        class="btn-complete"
        size="small"
        @click="handleUpdateStatus('completed', '标记为已完成？')"
      >
        已完成
      </ElButton>
      <ElButton
        v-if="
          props.id &&
          (status === 'pending' ||
            status === 'draft' ||
            status === 'confirmed' ||
            status === 'in_progress')
        "
        class="btn-cancel"
        size="small"
        @click="handleUpdateStatus('cancelled', '确定要取消该单据吗？')"
      >
        取消
      </ElButton>
    </div>

    <!-- 右侧进度条 -->
    <div class="status-stepper">
      <div
        v-for="(step, index) in displaySteps"
        :key="step.value"
        class="stepper-item"
        :class="{
          'is-active': index <= currentStepIndex && status !== 'cancelled',
          'is-warning': index <= currentStepIndex && status === 'cancelled',
          'is-process': index === currentStepIndex,
          'is-wait': index > currentStepIndex
        }"
        @click="handleStepClick(step.value)"
      >
        <span class="stepper-label">{{ step.label }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { ElButton, ElMessageBox, ElMessage } from 'element-plus'

  interface Props {
    status: string
    id?: string | number
    readonly?: boolean
  }

  const props = withDefaults(defineProps<Props>(), {
    id: undefined,
    readonly: false
  })

  const emit = defineEmits(['change', 'close'])

  // 判断是否为最终状态
  const isFinalStatus = computed(() => {
    return props.status === 'completed' || props.status === 'cancelled'
  })

  // 动态计算显示的步骤
  const displaySteps = computed(() => {
    const steps = [
      { value: 'pending', label: '草稿' },
      { value: 'confirmed', label: '已确认' }
    ]
    if (props.status === 'cancelled') {
      steps.push({ value: 'cancelled', label: '已取消' })
    } else {
      steps.push({ value: 'completed', label: '已完成' })
    }
    return steps
  })

  // 状态映射：draft->pending, in_progress->confirmed
  const normalizedStatus = computed(() => {
    if (props.status === 'draft') return 'pending'
    if (props.status === 'in_progress') return 'confirmed'
    return props.status
  })

  // 计算当前步骤索引
  const currentStepIndex = computed(() => {
    const index = displaySteps.value.findIndex((step) => step.value === normalizedStatus.value)
    return index >= 0 ? index : 0
  })

  /**
   * 统一更新状态逻辑
   */
  const handleUpdateStatus = async (nextStatus: string, confirmText: string) => {
    if (!props.id) {
      if (nextStatus === 'cancelled') {
        emit('close')
        return
      }
      ElMessage.warning('请先提交单据生成记录')
      return
    }

    try {
      await ElMessageBox.confirm(confirmText, '状态变更', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      emit('change', nextStatus)
    } catch {
      // cancel
    }
  }

  /**
   * 点击步骤条切换状态
   */
  const handleStepClick = (val: string) => {
    if (!props.id || isFinalStatus.value || props.readonly) return
    if (val === props.status) return

    const stepLabel = displaySteps.value.find((s) => s.value === val)?.label
    handleUpdateStatus(val, `确定要将状态手动切换为 [${stepLabel}] 吗？`)
  }
</script>

<style scoped lang="scss">
  .status-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 0;
    margin-bottom: 16px;
    border-bottom: 1px solid #ebeef5;

    .status-actions {
      display: flex;
      gap: 6px;

      .btn-confirm,
      .btn-complete {
        font-weight: 500;
        color: #fff;
        background-color: #5b45a8;
        border-color: #5b45a8;

        &:hover {
          background-color: #4a368d;
          border-color: #4a368d;
        }
      }

      .btn-cancel {
        color: #606266;
        background-color: #f2f3f5;
        border-color: #dcdfe6;

        &:hover {
          color: #323233;
          background-color: #e5e6eb;
        }
      }
    }

    .status-stepper {
      display: flex;
      align-items: center;
      padding-left: 10px;
      margin-left: auto;

      .stepper-item {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        height: 28px;
        padding: 0 15px 0 20px;
        margin-left: -10px;
        clip-path: polygon(
          calc(100% - 10px) 0%,
          100% 50%,
          calc(100% - 10px) 100%,
          0% 100%,
          10px 50%,
          0% 0%
        );
        cursor: pointer;
        background-color: #dcdfe6;
        transition: all 0.3s;

        &::after {
          position: absolute;
          inset: 1px;
          z-index: 1;
          clip-path: polygon(
            calc(100% - 10px) 0%,
            100% 50%,
            calc(100% - 10px) 100%,
            0% 100%,
            10px 50%,
            0% 0%
          );
          content: '';
          background-color: #f2f3f5;
        }

        &:first-child {
          padding-left: 12px;
          margin-left: 0;
          clip-path: polygon(
            calc(100% - 10px) 0%,
            100% 50%,
            calc(100% - 10px) 100%,
            0% 100%,
            0% 0%
          );

          &::after {
            clip-path: polygon(
              calc(100% - 10px) 0%,
              100% 50%,
              calc(100% - 10px) 100%,
              0% 100%,
              0% 0%
            );
          }
        }

        &:last-child {
          padding-right: 12px;
          clip-path: polygon(100% 0%, 100% 100%, 0% 100%, 10px 50%, 0% 0%);

          &::after {
            clip-path: polygon(100% 0%, 100% 100%, 0% 100%, 10px 50%, 0% 0%);
          }
        }

        .stepper-label {
          position: relative;
          z-index: 5;
          font-size: 12px;
          color: #6b7280;
          white-space: nowrap;
        }

        &.is-active,
        &.is-process {
          z-index: 10;
          background-color: #5b45a8;

          &::after {
            background-color: #e9e3f7;
          }

          .stepper-label {
            font-weight: bold;
            color: #000;
          }
        }

        &.is-warning {
          z-index: 10;
          background-color: #e6a23c;

          &::after {
            background-color: #fdf6ec;
          }

          .stepper-label {
            font-weight: bold;
            color: #000;
          }
        }
      }
    }
  }
</style>
