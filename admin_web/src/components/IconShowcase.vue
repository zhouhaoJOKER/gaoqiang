<template>
  <div class="icon-showcase-container">
    <input v-model="searchQuery" type="text" class="search-input" placeholder="搜索图标名称..." />
    <div class="icon-grid">
      <div v-for="iconName in filteredIcons" :key="iconName" class="icon-item">
        <ArtSvgIcon :icon="`ri:${iconName}`" class="icon" />
        <span class="icon-name">{{ iconName }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed } from 'vue'
  import * as ArtSvgIconModule from './core/base/art-svg-icon/index.vue'
  const ArtSvgIcon = (ArtSvgIconModule as any).default || (ArtSvgIconModule as any)
  import riIcons from '@iconify-json/ri/icons.json'

  // 获取所有ri图标名称
  const allIcons = Object.keys((riIcons as any).icons || {})

  // 搜索查询
  const searchQuery = ref('')

  // 过滤图标
  const filteredIcons = computed(() => {
    const query = searchQuery.value.toLowerCase()
    return allIcons.filter((iconName) => iconName.toLowerCase().includes(query))
  })
</script>

<style scoped>
  .icon-showcase-container {
    max-width: 1200px;
    padding: 18px;
    margin: 0 auto;
  }

  .search-input {
    width: 100%;
    padding: 12px 20px;
    margin-bottom: 20px;
    font-size: 16px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgb(0 0 0 / 10%);
  }

  .icon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 16px;
  }

  .icon-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px;
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

  .icon {
    margin-bottom: 12px;
    font-size: 32px;
    color: #1890ff;
  }

  .icon-name {
    font-size: 14px;
    color: #333;
    text-align: center;
    word-break: break-word;
  }
</style>
