<template>
  <div class="crm-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack"
          ><ArtSvgIcon icon="ri:arrow-left-line"
        /></ElButton>
        <span class="header-name">{{ detailData.name || '联系人详情' }}</span>
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
                  ><span class="info-label">所属客户</span
                  ><span class="info-value">{{ detailData.client_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">姓名</span
                  ><span class="info-value">{{ detailData.name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">部门</span
                  ><span class="info-value">{{ detailData.dept || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">职务</span
                  ><span class="info-value">{{ detailData.title || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">电话</span
                  ><span class="info-value">{{ detailData.phone || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">手机</span
                  ><span class="info-value">{{ detailData.mobile || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">邮箱</span
                  ><span class="info-value">{{ detailData.email || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">主联系人</span
                  ><span class="info-value">{{ detailData.is_primary ? '是' : '否' }}</span></div
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
    <ContactDialog
      v-model="editDialogVisible"
      :contact="detailData"
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
  import ContactDialog from './modules/contact-dialog.vue'
  import { viewCrmContactApi } from '@/api/crm/contact'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'CrmContactDetail' })

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
      const res = await viewCrmContactApi({ id: detailId.value })
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
