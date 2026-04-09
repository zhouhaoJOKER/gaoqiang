<!-- 日志管理页面 -->
<template>
  <div class="pt-5 art-page-view">
    <div class="art-card-header">
      <div class="title">
        <h4>日志管理</h4>
      </div>
    </div>

    <el-card class="mt-4">
      <el-tabs
        v-model="activeTab"
        @tab-change="(name: string | number) => handleTabChange(String(name))"
      >
        <el-tab-pane label="操作日志" name="10"> </el-tab-pane>
        <el-tab-pane label="安全日志" name="20"> </el-tab-pane>
        <el-tab-pane label="登录日志" name="0"> </el-tab-pane>
        <el-tab-pane label="审计日志" name="30"> </el-tab-pane>
      </el-tabs>
      <!-- 只使用一个LogTable组件，根据activeTab动态传递category -->
      <LogTable :category="activeTab" />
    </el-card>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'Log' })

  import { ref } from 'vue'
  import LogTable from './modules/LogTable.vue'

  // 状态管理
  const activeTab = ref('10')

  // 处理标签页切换
  const handleTabChange = (tab: string) => {
    activeTab.value = tab
    // 切换标签页时，LogTable 组件会根据新的 category prop 自动重新加载数据
  }
</script>

<style scoped>
  .log-container {
    width: 100%;
    height: 100%;
  }
</style>
