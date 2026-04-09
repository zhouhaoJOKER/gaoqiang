<template>
  <div class="base-properties">
    <div class="properties-header">
      <h4 class="page-title">属性管理</h4>
      <p class="page-desc">按标识(sign)分类展示，支持新增与编辑</p>
    </div>
    <div class="properties-body">
      <div v-for="group in groupedBySign" :key="group.sign" class="sign-card">
        <div class="sign-card-header">
          <span class="sign-title">{{ group.sign || '未分类' }}</span>
          <ElButton type="primary" size="small" @click="openDialog(group.sign)"
            ><ArtSvgIcon icon="ri:add-line" /> 新增</ElButton
          >
        </div>
        <ElTable :data="group.list" border size="small" class="sign-table black-text">
          <ElTableColumn type="index" width="45" label="序号" />
          <ElTableColumn label="名称" min-width="100">
            <template #default="{ row }">
              <span class="property-name-tag" :style="getTagStyle(row)">{{ row.name || '-' }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="abbr" label="缩写" width="60" />
          <ElTableColumn prop="py" label="拼音/检索" width="80" />
          <ElTableColumn prop="sort" label="排序" width="55" />
          <ElTableColumn label="颜色" width="70">
            <template #default="{ row }">
              <span
                v-if="row.color"
                class="color-dot"
                :style="{ background: row.bg_color || row.color }"
              />
              {{ row.color || '-' }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="启用" width="58">
            <template #default="{ row }">
              <ElTag :type="row.is_open !== false ? 'success' : 'info'" size="small">{{
                row.is_open !== false ? '是' : '否'
              }}</ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="86" fixed="right">
            <template #default="{ row }">
              <ArtButtonMore
                :list="[
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ]"
                @click="(item) => buttonPropertyClick(item, row, group.sign)"
              />
            </template>
          </ElTableColumn>
        </ElTable>
      </div>
      <div v-if="loading" class="loading-wrap"
        ><ElIcon class="is-loading"><Loading /></ElIcon> 加载中...</div
      >
      <div v-else-if="!groupedBySign.length" class="empty-tip">暂无属性数据</div>
    </div>
    <PropertyFormDialog
      v-model="formDialogVisible"
      :sign="currentSign"
      :property="currentProperty"
      @created="onFormCreated"
      @updated="onFormUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { Loading } from '@element-plus/icons-vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ElButton, ElTable, ElTableColumn, ElTag, ElIcon } from 'element-plus'
  import { listPropertyApi, deletePropertyApi } from '@/api/property'
  import PropertyFormDialog from './modules/property-form-dialog.vue'

  defineOptions({ name: 'BaseProperties' })

  const loading = ref(false)
  const propertyList = ref<any[]>([])
  const formDialogVisible = ref(false)
  const currentSign = ref<string>('')
  const currentProperty = ref<any>(undefined)

  const groupedBySign = computed(() => {
    const map = new Map<string, any[]>()
    for (const p of propertyList.value) {
      const sign = p.sign || '__none__'
      if (!map.has(sign)) map.set(sign, [])
      map.get(sign)!.push(p)
    }
    return Array.from(map.entries()).map(([sign, list]) => ({
      sign: sign === '__none__' ? '' : sign,
      list: list.sort((a, b) => (Number(a.sort) || 0) - (Number(b.sort) || 0))
    }))
  })

  const fetchList = async () => {
    loading.value = true
    try {
      const res = await listPropertyApi({ per_page: 2000 })
      const data = (res as any).data || []
      propertyList.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      propertyList.value = []
    } finally {
      loading.value = false
    }
  }

  const openDialog = (sign: string, property?: any) => {
    currentSign.value = sign
    currentProperty.value = property
    formDialogVisible.value = true
  }

  const getTagStyle = (row: any): Record<string, string> => {
    const token = (row.color || row.bg_color || '').toLowerCase()
    if (!token || token === 'noset') {
      return {
        backgroundColor: 'var(--el-fill-color-light)',
        borderColor: 'var(--el-border-color)',
        color: 'var(--el-text-color-regular)'
      }
    }
    if (token.startsWith('--')) {
      return {
        backgroundColor: `var(${token})`,
        borderColor: `var(${token})`,
        color: `var(${token})`
      }
    }
    return {
      backgroundColor: `var(--el-color-${token}-light-9)`,
      borderColor: `var(--el-color-${token})`,
      color: `var(--el-color-${token})`
    }
  }

  const buttonPropertyClick = (item: { key: string | number }, row: any, sign: string) => {
    if (item.key === 'edit') openDialog(sign, row)
    else if (item.key === 'delete') handleDelete(row)
  }

  const onFormCreated = () => {
    fetchList()
    formDialogVisible.value = false
  }
  const onFormUpdated = () => {
    fetchList()
    formDialogVisible.value = false
  }

  const handleDelete = (row: any) => {
    ElMessageBox.confirm(`确定删除“${row.name}”吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deletePropertyApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          fetchList()
        })
      )
      .catch(() => {})
  }

  onMounted(() => fetchList())
</script>

<style scoped lang="scss">
  .base-properties {
    padding: 16px;
  }

  .properties-header {
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

  .properties-body {
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .sign-card {
    overflow: hidden;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
  }

  .sign-card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: var(--el-fill-color-light);
    border-bottom: 1px solid var(--el-border-color);
  }

  .sign-title {
    font-weight: 600;
  }

  .sign-table {
    width: 100% !important;
    margin: 0;
  }

  .sign-table.black-text :deep(.el-table__body td),
  .sign-table.black-text :deep(.el-table__header th) {
    color: #000;
  }

  .property-name-tag {
    display: inline-block;
    padding: 2px 8px;
    font-size: 12px;
    line-height: 1.4;
    border: 1px solid;
    border-radius: 4px;
  }

  .color-dot {
    display: inline-block;
    width: 12px;
    height: 12px;
    margin-right: 4px;
    vertical-align: middle;
    border-radius: 50%;
  }

  .loading-wrap,
  .empty-tip {
    padding: 24px;
    color: var(--el-text-color-secondary);
    text-align: center;
  }
</style>
