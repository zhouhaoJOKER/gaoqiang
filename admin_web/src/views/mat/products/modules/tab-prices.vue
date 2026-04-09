<template>
  <div class="empty-tab">
    <div class="empty-text">该功能暂未实现</div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'TabPrices' })
</script>

<style scoped lang="scss">
  .empty-tab {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 240px;
    color: var(--el-text-color-placeholder);
  }

  .empty-text {
    font-size: 14px;
  }
</style>
