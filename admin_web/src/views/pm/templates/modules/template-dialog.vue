<!-- 项目模板弹窗 -->
<template>
  <ElDialog
    :title="dialogTitle"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="600px"
    align-center
    class="template-dialog"
    @closed="handleClosed"
  >
    <div class="template-form">
      <!-- 模板名称 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:file-text-line" class="mr-2" />
          <span>模板名称</span>
        </div>
        <ElInput v-model="form.name" placeholder="输入模板名称" size="large" clearable />
      </div>

      <!-- 模板 Logo -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:image-line" class="mr-2" />
          <span>模板 Logo</span>
        </div>
        <div class="logo-upload-container">
          <!-- Logo 预览 -->
          <div v-if="form.logo" class="logo-preview">
            <img :src="getImageUrl(form.logo)" :alt="form.name" class="logo-image" />
            <div class="logo-overlay">
              <ElButton
                text
                type="danger"
                size="small"
                @click="handleRemoveLogo"
                class="remove-btn"
              >
                <ArtSvgIcon icon="ri:delete-bin-line" class="mr-1" />
                删除
              </ElButton>
            </div>
          </div>
          <!-- 上传区域 -->
          <div v-else class="logo-upload-wrapper">
            <div class="logo-upload-placeholder">
              <ArtSvgIcon icon="ri:upload-cloud-2-line" class="text-2xl mb-2 text-g-400" />
              <div class="text-sm text-g-500 mb-2">点击上传 Logo</div>
              <ImageUploadDialog @upload-success="handleLogoUploadSuccess" />
            </div>
          </div>
        </div>
      </div>

      <!-- 模板描述 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:file-text-line" class="mr-2" />
          <span>模板描述</span>
        </div>
        <ElInput
          v-model="form.description"
          type="textarea"
          :rows="4"
          placeholder="请输入模板描述"
          maxlength="1000"
          show-word-limit
        />
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">完成</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { reactive, computed, watch, nextTick } from 'vue'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ImageUploadDialog from '@/components/ImageUploadDialog.vue'

  interface TemplateFormData {
    id?: string | number
    name: string
    description?: string
    logo?: string
  }

  interface Props {
    visible: boolean
    editData?: any
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit', data: TemplateFormData): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false
  })

  const emit = defineEmits<Emits>()

  const form = reactive<TemplateFormData>({
    name: '',
    description: '',
    logo: ''
  })

  const dialogTitle = computed(() => {
    return props.editData ? '编辑模板' : '新建模板'
  })

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
   * 处理 Logo 上传成功
   */
  const handleLogoUploadSuccess = (url: string): void => {
    form.logo = url
  }

  /**
   * 删除 Logo
   */
  const handleRemoveLogo = (): void => {
    form.logo = ''
  }

  /**
   * 重置表单
   */
  const resetForm = (): void => {
    form.name = ''
    form.description = ''
    form.logo = ''
  }

  /**
   * 加载表单数据（编辑模式）
   */
  const loadFormData = (): void => {
    if (!props.editData) return

    const row = props.editData
    form.name = row.name || ''
    form.description = row.description || ''
    form.logo = row.logo || ''
  }

  /**
   * 提交表单
   */
  const handleSubmit = async (): Promise<void> => {
    if (!form.name.trim()) {
      ElMessage.warning('请输入模板名称')
      return
    }

    const submitData: TemplateFormData = {
      ...form
    }

    emit('submit', submitData)
    handleCancel()
  }

  /**
   * 取消操作
   */
  const handleCancel = (): void => {
    emit('update:visible', false)
  }

  /**
   * 对话框关闭后的回调
   */
  const handleClosed = (): void => {
    resetForm()
  }

  /**
   * 监听对话框显示状态
   */
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        resetForm()
        nextTick(() => {
          if (props.editData) {
            loadFormData()
          }
        })
      }
    }
  )
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .template-form {
    @apply space-y-4;
  }

  .form-item {
    @apply space-y-2;
  }

  .form-item-label {
    @apply flex items-center text-sm font-medium text-g-700;
  }

  .logo-upload-container {
    @apply space-y-2;
  }

  .logo-preview {
    @apply relative w-32 h-32 rounded-lg overflow-hidden border border-g-200;
  }

  .logo-image {
    @apply w-full h-full object-cover;
  }

  .logo-overlay {
    @apply absolute inset-0 bg-black/0 hover:bg-black/50 transition-all duration-200 flex items-center justify-center;
  }

  .logo-preview:hover .logo-overlay {
    @apply bg-black/50;
  }

  .remove-btn {
    @apply opacity-0;
  }

  .logo-preview:hover .remove-btn {
    @apply opacity-100;
  }

  .logo-upload-wrapper {
    @apply w-32;
  }

  .logo-upload-placeholder {
    @apply w-32 h-32 rounded-lg border-2 border-dashed border-g-300 flex flex-col items-center justify-center cursor-pointer transition-colors;

    border-color: var(--el-border-color);
  }

  .logo-upload-placeholder:hover {
    border-color: var(--el-color-primary);
  }

  .dialog-footer {
    @apply flex justify-end gap-3;
  }
</style>
