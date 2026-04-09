<template>
  <div class="crm-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack"
          ><ArtSvgIcon icon="ri:arrow-left-line"
        /></ElButton>
        <span class="header-name">{{ detailData.name || '指标项目详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh"
          ><ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新</ElButton
        >
        <ElButton type="primary" @click="handleEdit">编辑</ElButton>
      </div>
    </div>
    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <ElCard shadow="never" class="info-card-single">
          <div class="info-card-body">
            <div class="info-block">
              <div class="info-block-title">基本信息</div>
              <div class="info-rows">
                <div class="info-row"
                  ><span class="info-label">项目编号</span
                  ><span class="info-value">{{ detailData.code || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">项目名称</span
                  ><span class="info-value">{{ detailData.name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">英文名称</span
                  ><span class="info-value">{{ detailData.name_en || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">排序</span
                  ><span class="info-value">{{ detailData.sort ?? '-' }}</span></div
                >
                <div class="info-row info-row-full"
                  ><span class="info-label">备注</span
                  ><span class="info-value">{{ detailData.remark || '-' }}</span></div
                >
              </div>
            </div>
            <ElDivider direction="vertical" class="info-divider" />
            <div class="info-block">
              <div class="info-block-title">负责人信息</div>
              <div class="info-rows">
                <div class="info-row"
                  ><span class="info-label">创建人</span
                  ><span class="info-value">{{ detailData.user_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">创建时间</span
                  ><span class="info-value">{{
                    detailData.created_at || detailData.created_time || '-'
                  }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">更新人</span
                  ><span class="info-value">{{ detailData.updater_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">更新时间</span
                  ><span class="info-value">{{
                    detailData.updated_at || detailData.updated_time || '-'
                  }}</span></div
                >
              </div>
            </div>
          </div>
        </ElCard>
      </div>
    </div>
    <SpecItemDialog
      v-model="editDialogVisible"
      :spec-item="detailData"
      :readonly="false"
      @updated="handleUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import SpecItemDialog from './modules/spec-item-dialog.vue'
  import { viewCrmSpecItemApi } from '@/api/crm/spec-item'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'CrmSpecItemDetail' })
  const route = useRoute()
  const router = useRouter()
  const editDialogVisible = ref(false)
  const detailId = computed(() => {
    const id = route.params.id || route.query.id
    return Array.isArray(id) ? id[0] : id
  })
  const detailData = ref<Record<string, any>>({})
  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewCrmSpecItemApi({ id: detailId.value })
      detailData.value = (res as any).data || {}
    } catch {
      ElMessage.error('加载详情失败')
    }
  }
  const handleGoBack = () => router.back()
  const handleRefresh = () => loadDetail()
  const handleEdit = () => {
    editDialogVisible.value = true
  }
  const handleUpdated = (p: any) => {
    Object.assign(detailData.value, p)
    editDialogVisible.value = false
  }
  onMounted(() => loadDetail())
</script>

<style scoped lang="scss">
  @use '../detail-common.scss' as *;
</style>
