<template>
  <div class="department-view-page art-full-height">
    <!-- 面包屑导航 -->
    <div class="mb-4">
      <ElBreadcrumb separator="/">
        <ElBreadcrumbItem :to="{ path: '/system/department' }">部门管理</ElBreadcrumbItem>
        <ElBreadcrumbItem>部门详情</ElBreadcrumbItem>
      </ElBreadcrumb>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="flex items-center justify-center h-64">
      <ElIcon class="is-loading" :size="40">
        <Loading />
      </ElIcon>
    </div>

    <!-- 详情内容 -->
    <div v-else class="department-detail">
      <!-- 顶部操作栏 -->
      <div class="detail-header mb-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-4">
            <ElIcon :size="48" class="text-primary">
              <OfficeBuilding />
            </ElIcon>
            <div>
              <h2 class="text-2xl font-bold">{{ departmentData?.name || '-' }}</h2>
              <p class="text-gray-500 text-sm mt-1">
                {{ departmentData?.code ? `编码: ${departmentData.code}` : '' }}
              </p>
            </div>
          </div>
          <div class="flex gap-2">
            <ElButton @click="goBack" v-ripple>
              <ElIcon><ArrowLeft /></ElIcon>
              返回
            </ElButton>
            <ElButton type="primary" @click="handleEdit" v-ripple v-if="hasAuth('edit')">
              <ElIcon><Edit /></ElIcon>
              编辑
            </ElButton>
          </div>
        </div>
      </div>

      <!-- 主要信息卡片 -->
      <ElRow :gutter="20">
        <!-- 基本信息卡片 -->
        <ElCol :xs="24" :sm="24" :md="12" :lg="8" class="mb-4">
          <ElCard shadow="hover" class="h-full">
            <template #header>
              <div class="flex items-center gap-2">
                <ElIcon><InfoFilled /></ElIcon>
                <span class="font-semibold">基本信息</span>
              </div>
            </template>
            <div class="info-list">
              <div class="info-item">
                <span class="label">部门名称：</span>
                <span class="value">{{ departmentData?.name || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="label">部门编码：</span>
                <span class="value">{{ departmentData?.code || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="label">上级部门：</span>
                <span class="value">{{ departmentData?.parent_name || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="label">负责人：</span>
                <span class="value">{{ departmentData?.manager_name || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="label">排序：</span>
                <span class="value">{{ departmentData?.sort || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="label">状态：</span>
                <ElTag :type="departmentData?.status ? 'success' : 'danger'">
                  {{ departmentData?.status ? '启用' : '禁用' }}
                </ElTag>
              </div>
            </div>
          </ElCard>
        </ElCol>

        <!-- 时间信息卡片 -->
        <ElCol :xs="24" :sm="24" :md="12" :lg="8" class="mb-4">
          <ElCard shadow="hover" class="h-full">
            <template #header>
              <div class="flex items-center gap-2">
                <ElIcon><Clock /></ElIcon>
                <span class="font-semibold">时间信息</span>
              </div>
            </template>
            <div class="info-list">
              <div class="info-item">
                <span class="label">创建时间：</span>
                <span class="value">{{ formatDate(departmentData?.created_at) }}</span>
              </div>
              <div class="info-item">
                <span class="label">更新时间：</span>
                <span class="value">{{ formatDate(departmentData?.updated_at) }}</span>
              </div>
            </div>
          </ElCard>
        </ElCol>

        <!-- 统计信息卡片 -->
        <ElCol :xs="24" :sm="24" :md="12" :lg="8" class="mb-4">
          <ElCard shadow="hover" class="h-full">
            <template #header>
              <div class="flex items-center gap-2">
                <ElIcon><DataAnalysis /></ElIcon>
                <span class="font-semibold">统计信息</span>
              </div>
            </template>
            <div class="stats-list">
              <div class="stat-item">
                <div class="stat-icon bg-blue-100">
                  <ElIcon class="text-blue-600"><FolderOpened /></ElIcon>
                </div>
                <div class="stat-content">
                  <div class="stat-value">{{ departmentData?.children_count || 0 }}</div>
                  <div class="stat-label">子部门</div>
                </div>
              </div>
              <div class="stat-item">
                <div class="stat-icon bg-green-100">
                  <ElIcon class="text-green-600"><User /></ElIcon>
                </div>
                <div class="stat-content">
                  <div class="stat-value">{{ departmentData?.user_count || 0 }}</div>
                  <div class="stat-label">员工数量</div>
                </div>
              </div>
            </div>
          </ElCard>
        </ElCol>
      </ElRow>

      <!-- 描述信息卡片 -->
      <ElRow :gutter="20">
        <ElCol :span="24" class="mb-4">
          <ElCard shadow="hover">
            <template #header>
              <div class="flex items-center gap-2">
                <ElIcon><Document /></ElIcon>
                <span class="font-semibold">部门描述</span>
              </div>
            </template>
            <div class="description-content">
              {{ departmentData?.remark || '暂无描述' }}
            </div>
          </ElCard>
        </ElCol>
      </ElRow>

      <!-- 子部门列表 -->
      <ElRow :gutter="20" v-if="departmentData?.children && departmentData.children.length > 0">
        <ElCol :span="24" class="mb-4">
          <ElCard shadow="hover">
            <template #header>
              <div class="flex items-center gap-2">
                <ElIcon><FolderOpened /></ElIcon>
                <span class="font-semibold">子部门列表</span>
              </div>
            </template>
            <div class="children-list">
              <div
                v-for="child in departmentData.children"
                :key="child.id"
                class="child-item"
                @click="viewChildDepartment(child.id)"
              >
                <div class="child-icon">
                  <ElIcon><OfficeBuilding /></ElIcon>
                </div>
                <div class="child-info">
                  <div class="child-name">{{ child.name }}</div>
                  <div class="child-code">{{ child.code || '无编码' }}</div>
                </div>
                <ElIcon class="child-arrow"><ArrowRight /></ElIcon>
              </div>
            </div>
          </ElCard>
        </ElCol>
      </ElRow>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import {
    Loading,
    ArrowLeft,
    Edit,
    InfoFilled,
    Clock,
    DataAnalysis,
    FolderOpened,
    User,
    Document,
    OfficeBuilding,
    ArrowRight
  } from '@element-plus/icons-vue'
  import { viewDepartmentApi } from '@/api/department'
  import { useAuth } from '@/hooks/core/useAuth'

  defineOptions({ name: 'DepartmentView' })

  const route = useRoute()
  const router = useRouter()
  const { hasAuth } = useAuth()

  // 状态管理
  const loading = ref(false)
  const departmentData = ref<any>(null)

  // 获取部门详情
  const getDepartmentDetail = async () => {
    const id = route.params.id
    if (!id) {
      ElMessage.error('缺少部门ID')
      goBack()
      return
    }

    loading.value = true
    try {
      const response = await viewDepartmentApi({ id })
      if (response && response.code === 200) {
        departmentData.value = response.data
      } else {
        ElMessage.error('获取部门详情失败')
      }
    } catch (error: any) {
      console.error('获取部门详情失败:', error)
      ElMessage.error(error.message || '获取部门详情失败')
    } finally {
      loading.value = false
    }
  }

  // 返回列表
  const goBack = () => {
    router.push('/system/department')
  }

  // 编辑部门
  const handleEdit = () => {
    // 这里可以跳转到编辑页面或打开编辑弹窗
    ElMessage.info('编辑功能待实现')
  }

  // 查看子部门
  const viewChildDepartment = (id: number) => {
    router.push(`/system/department/view/${id}`)
  }

  // 格式化日期
  const formatDate = (date: string) => {
    if (!date) return '-'
    return new Date(date).toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  // 页面加载时获取数据
  onMounted(() => {
    getDepartmentDetail()
  })
</script>

<style scoped lang="scss">
  .department-view-page {
    padding: 20px;
  }

  .detail-header {
    padding: 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgb(0 0 0 / 5%);
  }

  .info-list {
    .info-item {
      display: flex;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid #f0f0f0;

      &:last-child {
        border-bottom: none;
      }

      .label {
        min-width: 100px;
        font-weight: 500;
        color: #666;
      }

      .value {
        flex: 1;
        color: #333;
      }
    }
  }

  .stats-list {
    display: flex;
    flex-direction: column;
    gap: 16px;

    .stat-item {
      display: flex;
      gap: 12px;
      align-items: center;
      padding: 16px;
      background: #f8f9fa;
      border-radius: 8px;
      transition: all 0.3s;

      &:hover {
        background: #e9ecef;
        transform: translateY(-2px);
      }

      .stat-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        font-size: 24px;
        border-radius: 8px;
      }

      .stat-content {
        flex: 1;

        .stat-value {
          font-size: 24px;
          font-weight: bold;
          color: #333;
        }

        .stat-label {
          margin-top: 4px;
          font-size: 14px;
          color: #666;
        }
      }
    }
  }

  .description-content {
    min-height: 80px;
    padding: 8px 0;
    line-height: 1.6;
    color: #666;
  }

  .children-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;

    .child-item {
      display: flex;
      gap: 12px;
      align-items: center;
      padding: 16px;
      cursor: pointer;
      background: #f8f9fa;
      border: 1px solid transparent;
      border-radius: 8px;
      transition: all 0.3s;

      &:hover {
        background: white;
        border-color: #409eff;
        box-shadow: 0 2px 8px rgb(64 158 255 / 15%);
        transform: translateY(-2px);
      }

      .child-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 40px;
        height: 40px;
        font-size: 20px;
        color: #1890ff;
        background: #e6f7ff;
        border-radius: 8px;
      }

      .child-info {
        flex: 1;

        .child-name {
          margin-bottom: 4px;
          font-weight: 500;
          color: #333;
        }

        .child-code {
          font-size: 12px;
          color: #999;
        }
      }

      .child-arrow {
        color: #999;
        transition: all 0.3s;
      }

      &:hover .child-arrow {
        color: #409eff;
        transform: translateX(4px);
      }
    }
  }

  @media (width <= 768px) {
    .department-view-page {
      padding: 12px;
    }

    .detail-header {
      padding: 16px;
    }

    .children-list {
      grid-template-columns: 1fr;
    }
  }
</style>
