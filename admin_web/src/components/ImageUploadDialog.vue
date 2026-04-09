<template>
  <!-- 隐藏的容器，只用于暴露方法，对话框会通过 Teleport 渲染到 body -->
  <Teleport to="body">
    <ElDialog
      v-model="dialogVisible"
      title="图片上传"
      width="500px"
      @close="resetFile"
      :z-index="3000"
    >
      <ElUpload
        ref="uploadRef"
        :drag="true"
        :auto-upload="false"
        :on-change="handleFileChange"
        :before-upload="beforeUpload"
        accept="image/*"
        class="upload-demo"
      >
        <ElIcon class="el-icon--upload"><UploadFilled /></ElIcon>
        <div class="el-upload__text">
          拖放图片到此处，或
          <em>点击上传</em>
        </div>
        <template #tip>
          <div class="el-upload__tip"> 只能上传图片文件，且不超过 2MB </div>
        </template>
      </ElUpload>

      <template #footer>
        <div class="flex justify-end">
          <ElButton @click="dialogVisible = false">取消</ElButton>
          <ElButton type="primary" @click="handleUpload" :loading="uploading">
            {{ uploading ? '上传中...' : '保存' }}
          </ElButton>
        </div>
      </template>
    </ElDialog>
  </Teleport>
</template>

<script setup lang="ts">
  import { ref } from 'vue'
  import { UploadFilled } from '@element-plus/icons-vue'
  import { ElMessage, ElDialog, ElUpload, ElButton, ElIcon } from 'element-plus'
  import { uploadApi } from '@/api/system-manage'
  import type { UploadInstance, UploadProps } from 'element-plus'

  const emit = defineEmits<{
    (e: 'upload-success', url: string): void
  }>()

  const dialogVisible = ref(false)
  const uploadRef = ref<UploadInstance | null>(null)
  const uploading = ref(false)
  const currentFile = ref<File | null>(null)

  const openDialog = () => {
    dialogVisible.value = true
  }

  // 暴露方法供外部调用
  defineExpose({
    openDialog
  })

  const handleFileChange: UploadProps['onChange'] = (file) => {
    currentFile.value = file.raw as File
  }

  const beforeUpload = (file: File) => {
    const isImage = file.type.startsWith('image/')
    if (!isImage) {
      ElMessage.error('只能上传图片文件')
      return false
    }

    const isLt2M = file.size / 1024 / 1024 < 2
    if (!isLt2M) {
      ElMessage.error('图片大小不能超过 2MB')
      return false
    }

    return true
  }

  const handleUpload = async () => {
    if (!currentFile.value) {
      ElMessage.warning('请选择要上传的图片')
      return
    }

    if (!beforeUpload(currentFile.value)) {
      return
    }

    uploading.value = true

    try {
      const formData = new FormData()
      formData.append('file', currentFile.value)

      const response = await uploadApi(formData)

      if (response.code === 200 && response.url) {
        emit('upload-success', response.url)
        ElMessage.success('上传成功')
        dialogVisible.value = false
      } else {
        ElMessage.error('上传失败：' + (response.msg || '未知错误'))
      }
    } catch (error) {
      ElMessage.error('上传失败：网络错误')
      console.error('Upload error:', error)
    } finally {
      uploading.value = false
      resetFile()
    }
  }

  const resetFile = () => {
    currentFile.value = null
    uploadRef.value?.clearFiles()
  }
</script>

<style scoped>
  .upload-demo {
    margin-bottom: 20px;
  }
</style>
