<template>
  <div class="base-workflow-templates">
    <div class="page-header">
      <h4 class="page-title">流程配置</h4>
      <p class="page-desc">
        配置多套流程模板（如订购合同全流程、简化流程等），支持节点、边、分支结果的编排，供合同等业务使用
      </p>
    </div>
    <div class="page-body">
      <div class="toolbar">
        <ElButton type="primary" @click="openDialog()">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />新增模板
        </ElButton>
      </div>
      <ElTable v-loading="loading" :data="list" border stripe>
        <ElTableColumn type="index" width="55" label="序号" />
        <ElTableColumn prop="code" label="模板编码" min-width="140" show-overflow-tooltip />
        <ElTableColumn prop="name" label="模板名称" min-width="160" show-overflow-tooltip />
        <ElTableColumn prop="description" label="描述" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="is_default" label="默认" width="80" align="center">
          <template #default="{ row }">
            <ElTag v-if="row.is_default" type="success" size="small">是</ElTag>
            <span v-else class="text-secondary">否</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="is_active" label="启用" width="80" align="center">
          <template #default="{ row }">
            <ElTag v-if="row.is_active !== false" type="success" size="small">是</ElTag>
            <ElTag v-else type="info" size="small">否</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="sort" label="排序" width="80" align="right" />
        <ElTableColumn label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <ElButton link type="primary" size="small" @click="goDetail(row)">编排</ElButton>
            <ElButton link type="primary" size="small" @click="openDialog(row)">编辑</ElButton>
            <ElButton link type="primary" size="small" @click="handleClone(row)">克隆</ElButton>
            <ElButton link type="danger" size="small" @click="handleDelete(row)">删除</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
      <div v-if="!loading && !list.length" class="empty-tip">暂无流程模板，请新增</div>
    </div>
    <WorkflowTemplateDialog
      v-model="dialogVisible"
      :template="currentTemplate"
      @created="onCreated"
      @updated="onUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn, ElTag } from 'element-plus'
  import { listWorkflowTemplatesApi, deleteWorkflowTemplateApi } from '@/api/fm/workflow'
  import WorkflowTemplateDialog from './modules/template-dialog.vue'

  defineOptions({ name: 'BaseWorkflowTemplates' })

  const router = useRouter()
  const loading = ref(false)
  const list = ref<any[]>([])
  const dialogVisible = ref(false)
  const currentTemplate = ref<any>(undefined)

  const fetchList = async () => {
    loading.value = true
    try {
      const res = await listWorkflowTemplatesApi({ per_page: 200 })
      const data = (res as any).data || []
      list.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  const openDialog = (template?: any) => {
    currentTemplate.value = template
    dialogVisible.value = true
  }

  const goDetail = (row: any) => {
    router.push({ name: 'BaseWorkflowTemplateDetail', params: { id: String(row.id) } })
  }

  const handleClone = (row: any) => {
    currentTemplate.value = {
      ...row,
      id: undefined,
      code: row.code ? `${row.code}_copy` : '',
      name: row.name ? `${row.name}（副本）` : '',
      is_default: false
    }
    dialogVisible.value = true
  }

  const handleDelete = (row: any) => {
    ElMessageBox.confirm(`确定删除流程模板「${row.name || row.code}」吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteWorkflowTemplateApi(Number(row.id)).then(() => {
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
  .base-workflow-templates {
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

    .text-secondary {
      color: var(--el-text-color-secondary);
    }
  }
</style>
