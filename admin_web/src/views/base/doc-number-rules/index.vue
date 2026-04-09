<template>
  <div class="base-doc-number-rules">
    <div class="page-header">
      <h4 class="page-title">单号配置</h4>
      <p class="page-desc"
        >配置各业务模块的单号生成规则，支持固定值、日期、序列号组合，可预览下一个单号</p
      >
    </div>
    <div class="page-body">
      <div class="toolbar">
        <ElButton type="primary" @click="openDialog()">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />新增规则
        </ElButton>
      </div>
      <ElTable v-loading="loading" :data="list" border stripe>
        <ElTableColumn type="index" width="55" label="序号" />
        <ElTableColumn prop="key" label="标识(key)" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="name" label="规则名称" min-width="120" show-overflow-tooltip />
        <ElTableColumn prop="format" label="格式模板" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="current_sequence" label="当前序列" width="90" align="right" />
        <ElTableColumn prop="reset_period" label="重置周期" width="90">
          <template #default="{ row }">
            <ElTag size="small">{{
              resetPeriodMap[row.reset_period] || row.reset_period || '-'
            }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="预览下一个" width="140">
          <template #default="{ row }">
            <ElButton
              link
              type="primary"
              size="small"
              :loading="previewLoading[row.id]"
              @click="handlePreview(row)"
            >
              {{ previewCode[row.id] ?? '点击预览' }}
            </ElButton>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <ElButton link type="primary" size="small" @click="openDialog(row)">编辑</ElButton>
            <ElButton link type="primary" size="small" @click="handleClone(row)">克隆</ElButton>
            <ElButton link type="danger" size="small" @click="handleDelete(row)">删除</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
      <div v-if="!loading && !list.length" class="empty-tip">暂无单号规则，请新增</div>
    </div>
    <DocNumberRuleDialog
      v-model="dialogVisible"
      :rule="currentRule"
      @created="onCreated"
      @updated="onUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn, ElTag } from 'element-plus'
  import {
    listDocNumberRuleApi,
    deleteDocNumberRuleApi,
    previewDocNumberApi
  } from '@/api/doc-number'
  import DocNumberRuleDialog from './modules/doc-number-rule-dialog.vue'

  defineOptions({ name: 'BaseDocNumberRules' })

  const resetPeriodMap: Record<string, string> = {
    none: '不重置',
    day: '按日',
    month: '按月',
    year: '按年'
  }

  const loading = ref(false)
  const list = ref<any[]>([])
  const dialogVisible = ref(false)
  const currentRule = ref<any>(undefined)
  const previewLoading = ref<Record<string | number, boolean>>({})
  const previewCode = ref<Record<string | number, string>>({})

  const fetchList = async () => {
    loading.value = true
    try {
      const res = await listDocNumberRuleApi({ per_page: 200 })
      const data = (res as any).data || []
      list.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  const openDialog = (rule?: any) => {
    currentRule.value = rule
    dialogVisible.value = true
  }

  /** 克隆：复制该行数据，以新建模式打开（key 需修改为唯一值） */
  const handleClone = (row: any) => {
    currentRule.value = {
      ...row,
      id: undefined,
      key: row.key ? `${row.key}_copy` : '',
      name: row.name ? `${row.name}（副本）` : '',
      current_sequence: 0
    }
    dialogVisible.value = true
  }

  const handlePreview = async (row: any) => {
    if (!row?.key) return
    previewLoading.value = { ...previewLoading.value, [row.id]: true }
    previewCode.value = { ...previewCode.value, [row.id]: '' }
    try {
      const res = await previewDocNumberApi(row.key)
      const d = (res as any).data || {}
      previewCode.value = { ...previewCode.value, [row.id]: d.code || '-' }
    } catch {
      previewCode.value = { ...previewCode.value, [row.id]: '预览失败' }
    } finally {
      previewLoading.value = { ...previewLoading.value, [row.id]: false }
    }
  }

  const handleDelete = (row: any) => {
    ElMessageBox.confirm(`确定删除规则「${row.name || row.key}」吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteDocNumberRuleApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          fetchList()
        })
      )
      .catch(() => {})
  }

  const onCreated = () => {
    fetchList()
    dialogVisible.value = false
  }
  const onUpdated = () => {
    fetchList()
    dialogVisible.value = false
  }

  onMounted(() => fetchList())
</script>

<style scoped lang="scss">
  .base-doc-number-rules {
    padding: 16px;
  }

  .page-header {
    margin-bottom: 16px;
  }

  .page-title {
    margin: 0 0 4px;
    font-size: 18px;
  }

  .page-desc {
    margin: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .page-body {
    .toolbar {
      margin-bottom: 12px;
    }

    .empty-tip {
      padding: 24px;
      color: var(--el-text-color-secondary);
      text-align: center;
    }
  }
</style>
