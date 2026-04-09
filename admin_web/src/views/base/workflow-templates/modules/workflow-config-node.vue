<template>
  <div
    class="workflow-config-node"
    :class="{ 'workflow-config-node--selected': selected }"
    @click="handleClick"
  >
    <Handle type="target" :position="Position.Top" class="workflow-handle" />
    <div class="workflow-config-node__label">{{ data?.label ?? data?.key ?? '' }}</div>
    <Handle type="source" :position="Position.Bottom" class="workflow-handle" />
  </div>
</template>

<script setup lang="ts">
  import { computed } from 'vue'
  import { Handle, Position } from '@vue-flow/core'
  import type { NodeProps } from '@vue-flow/core'

  const props = defineProps<NodeProps>()

  const emit = defineEmits<{ (e: 'click', node: unknown): void }>()

  const selected = computed(() => props.selected)

  function handleClick() {
    emit('click', props)
  }
</script>

<style scoped>
  .workflow-config-node {
    min-width: 88px;
    padding: 8px 14px;
    font-size: 12px;
    font-weight: 500;
    text-align: center;
    cursor: pointer;
    background: var(--el-fill-color-lighter);
    border: 2px solid var(--el-border-color);
    border-radius: 8px;
  }

  .workflow-config-node:hover {
    border-color: var(--el-color-primary-light-5);
  }

  .workflow-config-node--selected {
    background: var(--el-color-primary-light-9);
    border-color: var(--el-color-primary);
    box-shadow: 0 0 0 2px var(--el-color-primary-light-7);
  }

  .workflow-config-node__label {
    white-space: nowrap;
  }

  .workflow-handle {
    width: 8px;
    height: 8px;
    background: var(--el-border-color);
  }

  .workflow-config-node--selected .workflow-handle {
    background: var(--el-color-primary);
  }
</style>
