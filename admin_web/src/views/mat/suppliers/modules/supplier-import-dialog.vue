<template>
  <ElDialog v-model="dialogVisible" title="导入供应商" width="600px" :close-on-click-modal="false">
    <div class="import-container">
      <ElAlert type="info" :closable="false" class="mb-4">
        <template #default>
          <div>
            <p>请下载模板文件，按照模板格式填写数据后上传。</p>
            <ElButton text type="primary" @click="downloadTemplate">下载模板</ElButton>
          </div>
        </template>
      </ElAlert>
      <ElUpload
        ref="uploadRef"
        :auto-upload="false"
        :on-change="handleFileChange"
        :file-list="fileList"
        accept=".xlsx,.xls"
        drag
      >
        <ElIcon class="el-icon--upload"><upload-filled /></ElIcon>
        <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
        <template #tip>
          <div class="el-upload__tip">只能上传 xlsx/xls 文件</div>
        </template>
      </ElUpload>
    </div>
    <template #footer>
      <ElButton @click="handleClose">取消</ElButton>
      <ElButton type="primary" :loading="importing" @click="handleImport">导入</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import { ElMessage, ElButton, ElUpload, ElAlert, ElIcon } from 'element-plus'
  import { UploadFilled } from '@element-plus/icons-vue'

  defineOptions({ name: 'SupplierImportDialog' })

  const props = defineProps<{
    modelValue: boolean
  }>()

  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  const dialogVisible = ref(props.modelValue)
  const uploadRef = ref()
  const fileList = ref<any[]>([])
  const importing = ref(false)

  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (!newVal) {
        fileList.value = []
      }
    }
  )

  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  const downloadTemplate = () => {
    // 创建模板数据（待实现：使用 exportExcel 导出）
    const _templateData = [
      [
        '供应商名称',
        '供应商编码',
        '公司ID',
        '产品ID',
        '最小数量',
        '价格',
        '货币ID',
        '延迟天数',
        '主供应商',
        '排序'
      ]
    ]
    void _templateData
    ElMessage.info('模板下载功能待实现')
  }

  const handleFileChange = (file: any) => {
    fileList.value = [file]
  }

  const handleImport = async () => {
    if (fileList.value.length === 0) {
      ElMessage.warning('请先选择要导入的文件')
      return
    }

    importing.value = true
    try {
      // 这里需要实现文件解析和导入逻辑
      // 暂时提示待实现
      ElMessage.info('导入功能待实现，请使用批量添加功能')
      handleClose()
    } catch (error) {
      console.error('导入失败:', error)
      ElMessage.error('导入失败，请重试')
    } finally {
      importing.value = false
    }
  }

  const handleClose = () => {
    dialogVisible.value = false
    fileList.value = []
  }
</script>

<style scoped>
  .import-container {
    padding: 20px;
  }
</style>
