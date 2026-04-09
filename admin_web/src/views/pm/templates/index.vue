<!-- 项目模板列表页面 -->
<template>
  <div class="template-page art-full-height">
    <!-- 工具栏 -->
    <div class="flex items-center justify-between mb-4">
      <div class="text-lg font-medium text-g-900">项目模板</div>
      <ElButton type="primary" @click="handleCreate">
        <ArtSvgIcon icon="ri:add-line" class="mr-1" />
        新建模板
      </ElButton>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="flex items-center justify-center h-64">
      <ElIcon class="is-loading">
        <ArtSvgIcon icon="ri:loader-4-line" class="text-2xl text-primary-500" />
      </ElIcon>
    </div>

    <!-- 模板列表（卡片式展示，参照星标项目效果） -->
    <ElRow v-else-if="templateList.length" :gutter="20">
      <ElCol v-for="item in templateList" :key="item.id" :xs="24" :sm="12" :md="6" class="mb-5">
        <div class="relative template-card-wrapper">
          <ArtImageCard
            :imageUrl="getImageUrl(item.logo) || ''"
            :title="item.name || ''"
            :date="getTruncatedDescription(item.description)"
            @click="handleTemplateClick(item)"
          />
          <!-- 操作菜单 -->
          <div class="absolute top-2 right-2 z-10">
            <ElDropdown @command="(cmd) => handleCommand(cmd, item)" trigger="click">
              <ElButton text class="p-1 bg-white/80 hover:bg-white shadow-sm">
                <ArtSvgIcon icon="ri:more-2-line" class="text-base text-g-500" />
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem command="edit">
                    <ArtSvgIcon icon="ri:edit-line" class="mr-1" />
                    编辑
                  </ElDropdownItem>
                  <ElDropdownItem command="delete" divided>
                    <ArtSvgIcon icon="ri:delete-bin-line" class="mr-1" />
                    删除
                  </ElDropdownItem>
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </div>
        </div>
      </ElCol>
    </ElRow>

    <!-- 空状态 -->
    <div v-else-if="!loading" class="flex items-center justify-center h-64 text-sm text-g-400">
      <div class="text-center">
        <ArtSvgIcon icon="ri:file-list-3-line" class="text-4xl mb-2 text-g-300" />
        <div>暂无项目模板</div>
        <ElButton type="primary" text class="mt-2" @click="handleCreate">创建第一个模板</ElButton>
      </div>
    </div>

    <!-- 模板弹窗 -->
    <TemplateDialog v-model:visible="dialogVisible" :editData="editData" @submit="handleSubmit" />
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import {
    ElMessage,
    ElMessageBox,
    ElIcon,
    ElRow,
    ElCol,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElButton
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtImageCard from '@/components/core/cards/art-image-card/index.vue'
  import {
    listPmProjectTemplateApi,
    createPmProjectTemplateApi,
    updatePmProjectTemplateApi,
    deletePmProjectTemplateApi
  } from '@/api/pm/template'
  import TemplateDialog from './modules/template-dialog.vue'

  defineOptions({ name: 'PmProjectTemplates' })

  interface TemplateItem {
    id?: string | number
    name?: string
    description?: string
    logo?: string
    [key: string]: any
  }

  const loading = ref(false)
  const templateList = ref<TemplateItem[]>([])
  const dialogVisible = ref(false)
  const editData = ref<any>(null)

  /**
   * 获取图片 URL
   */
  const getImageUrl = (logo: string | undefined): string => {
    if (!logo) return ''
    // 如果已经是完整 URL，直接返回
    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return logo
    }
    // 如果是相对路径，直接返回（由代理处理）
    return logo.startsWith('/') ? logo : `/${logo}`
  }

  /**
   * 截断描述文本，最多显示一行
   */
  const getTruncatedDescription = (description: string | undefined): string | undefined => {
    if (!description) return undefined
    // 如果描述超过一定长度，截断并添加省略号
    // 根据卡片宽度，大约可以显示 30-40 个字符
    const maxLength = 40
    if (description.length > maxLength) {
      return description.substring(0, maxLength) + '...'
    }
    return description
  }

  /**
   * 获取模板列表
   */
  const getTemplateList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listPmProjectTemplateApi({
        current: 1,
        size: 100
      })
      const data = (res as any).data || {}
      // 处理响应数据，支持多种格式
      if (Array.isArray(data)) {
        templateList.value = data
      } else if (data.list || data.data || data.records) {
        templateList.value = data.list || data.data || data.records || []
      } else {
        templateList.value = []
      }
    } catch (error) {
      console.error('获取模板列表失败:', error)
      templateList.value = []
      ElMessage.error('获取模板列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 处理模板点击
   */
  const handleTemplateClick = (item: TemplateItem): void => {
    // 可以在这里实现模板预览或使用功能
    ElMessage.info(`点击了模板：${item.name}`)
  }

  /**
   * 处理下拉菜单命令
   */
  const handleCommand = (command: string, item: TemplateItem): void => {
    if (command === 'edit') {
      handleEdit(item)
    } else if (command === 'delete') {
      handleDelete(item)
    }
  }

  /**
   * 新建模板
   */
  const handleCreate = (): void => {
    editData.value = null
    dialogVisible.value = true
  }

  /**
   * 编辑模板
   */
  const handleEdit = (item: TemplateItem): void => {
    editData.value = item
    dialogVisible.value = true
  }

  /**
   * 删除模板
   */
  const handleDelete = (item: TemplateItem): void => {
    if (!item.id) {
      ElMessage.warning('模板ID不存在')
      return
    }

    ElMessageBox.confirm(
      `确定要删除模板"${item.name || '未命名'}"吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        try {
          await deletePmProjectTemplateApi(Number(item.id))
          ElMessage.success('删除成功')
          await getTemplateList()
        } catch (error) {
          console.error('删除模板失败:', error)
          ElMessage.error('删除失败')
        }
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  /**
   * 提交模板表单
   */
  const handleSubmit = async (formData: any): Promise<void> => {
    try {
      if (formData.id) {
        // 编辑
        await updatePmProjectTemplateApi(String(formData.id), formData)
        ElMessage.success('更新成功')
        getTemplateList()
      } else {
        // 新建
        await createPmProjectTemplateApi(formData)
        ElMessage.success('创建成功')
        getTemplateList()
      }
    } catch (error) {
      console.error('提交模板失败:', error)
      ElMessage.error('操作失败')
    }
  }

  onMounted(() => {
    getTemplateList()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .template-page {
    @apply p-4;
  }

  .template-card-wrapper {
    position: relative;
  }

  .template-card-wrapper:hover .template-actions {
    opacity: 1;
  }

  /* 限制描述显示为一行，超出部分显示省略号 */
  :deep(.art-card .flex-c span:last-child) {
    display: block;
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
</style>
