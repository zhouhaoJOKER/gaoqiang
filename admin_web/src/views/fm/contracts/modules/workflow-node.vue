<template>
  <div
    class="workflow-node"
    :class="[`workflow-node--${data?.status ?? 'pending'}`]"
    @click="handleClick"
  >
    <Handle type="target" :position="Position.Top" class="workflow-handle" />
    <div class="workflow-node__label">{{ data?.label ?? '' }}</div>
    <div v-if="data?.status === 'current'" class="workflow-node__action">
      <ElButton type="primary" size="small" @click.stop="onConfirm">确认</ElButton>
    </div>
    <Handle type="source" :position="Position.Bottom" class="workflow-handle" />
  </div>
</template>

<script setup lang="ts">
  import { Handle, Position } from '@vue-flow/core'
  import type { NodeProps } from '@vue-flow/core'

  const props = defineProps<NodeProps>()

  const emit = defineEmits<{ (e: 'confirm', node: unknown): void }>()

  function handleClick() {
    if (props.data?.status === 'current') {
      emit('confirm', props)
    }
  }

  function onConfirm() {
    emit('confirm', props)
  }
</script>

<style scoped>
  .workflow-node {
    min-width: 88px;
    padding: 8px 14px;
    font-size: 12px;
    font-weight: 500;
    text-align: center;
    cursor: default;
    background: var(--el-fill-color-lighter);
    border: 2px solid var(--el-border-color);
    border-radius: 8px;
  }

  .workflow-node--completed {
    color: var(--el-color-success-dark-2);
    background: var(--el-color-success-light-9);
    border-color: var(--el-color-success-light-5);
  }

  .workflow-node--current {
    color: var(--el-color-primary);
    cursor: pointer;
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary);
    box-shadow: 0 0 0 2px var(--el-color-primary-light-7);
  }

  .workflow-node--pending {
    color: var(--el-text-color-placeholder);
    opacity: 0.7;
  }

  .workflow-node--failed {
    color: var(--el-color-danger);
    background: var(--el-color-danger-light-9);
    border-color: var(--el-color-danger-light-5);
  }

  .workflow-node__label {
    white-space: nowrap;
  }

  .workflow-node__action {
    margin-top: 6px;
  }

  .workflow-handle {
    width: 8px;
    height: 8px;
    background: var(--el-border-color);
  }

  .workflow-node--completed .workflow-handle {
    background: var(--el-color-success);
  }

  .workflow-node--current .workflow-handle {
    background: var(--el-color-primary);
  }
</style>
