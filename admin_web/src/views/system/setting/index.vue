<!-- 角色管理页面 -->
<template>
  <div class="pt-5 art-page-view">
    <div class="art-card-header">
      <div class="title">
        <h4>系统设置</h4>
      </div>
      <el-radio-group v-model="tabPosition">
        <el-radio-button value="top">top</el-radio-button>
        <el-radio-button value="right">right</el-radio-button>
        <el-radio-button value="bottom">bottom</el-radio-button>
        <el-radio-button value="left">left</el-radio-button>
      </el-radio-group>
    </div>

    <el-tabs :tab-position="tabPosition" class="demo-tabs">
      <el-tab-pane label="系统设置">
        <Site />
      </el-tab-pane>
      <el-tab-pane label="邮件设置">
        <Mail />
      </el-tab-pane>
      <el-tab-pane label="企业协同">
        <Collaboration />
      </el-tab-pane>
      <el-tab-pane label="文件存储">
        <Storage />
      </el-tab-pane>
      <el-tab-pane label="安全配置">
        <Security />
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'Setting' })

  import { ref } from 'vue'
  import type { TabsInstance } from 'element-plus'
  import Site from './modules/site.vue'
  import Mail from './modules/mail.vue'
  import Collaboration from './modules/Collaboration.vue'
  import Storage from './modules/Storage.vue'
  import Security from './modules/Security.vue'

  const tabPosition = ref<TabsInstance['tabPosition']>('left')
</script>

<style></style>
