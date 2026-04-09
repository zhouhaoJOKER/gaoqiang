<!-- 用户导入弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="导入用户"
    min-width="800px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <el-card>
      <!-- 步骤指示器 -->
      <div class="steps-indicator mb-6">
        <ElSteps :active="currentStep" direction="horizontal" finish-status="success" align-center>
          <ElStep title="选择文件" />
          <ElStep title="预览修改" />
        </ElSteps>
      </div>

      <div class="import-container">
        <!-- 步骤1：选择文件 -->
        <div v-if="currentStep === 0" class="step-content">
          <!-- 导入类别 -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">导入类别</label>
            <ElRadioGroup v-model="importType">
              <ElRadio label="创建">创建</ElRadio>
              <ElRadio label="更新">更新</ElRadio>
            </ElRadioGroup>
          </div>

          <!-- 下载模板 -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              {{ importType }}模板下载
            </label>
            <ElLink type="primary" @click="handleDownloadTemplate('创建', 'csv')" class="mr-4">
              <i class="ri:ri-download-line"></i>
              CSV
            </ElLink>
            <ElLink type="primary" @click="handleDownloadTemplate('创建', 'xlsx')" class="mr-4">
              <i class="ri:ri-download-line"></i>
              XLSX
            </ElLink>
          </div>

          <!-- 上传文件 -->
          <div class="mb-6">
            <label class="block text-sm font-medium text-gray-700 mb-2">上传文件</label>
            <ElUpload
              ref="uploadRef"
              :auto-upload="false"
              :on-change="handleFileChange"
              :before-upload="beforeUpload"
              :file-list="fileList"
              accept=".xlsx,.csv"
              class="upload-demo"
            >
              <ElButton type="primary">
                <i class="ri-upload-cloud-line"></i>
                点击上传
              </ElButton>
              <template #tip>
                <div class="el-upload__tip text-gray-500">
                  仅允许上传 xlsx 或 csv 格式文件，单个文件大小不超过 5MB
                </div>
              </template>
            </ElUpload>
          </div>
        </div>

        <!-- 步骤2：预览修改 -->
        <div v-else-if="currentStep === 1" class="step-content">
          <!-- 预览数据 -->
          <div class="preview-section">
            <h3 class="text-sm font-medium text-gray-700 mb-3">数据预览与修改</h3>
            <p class="text-gray-500 mb-4">请检查并修改数据，然后提交导入</p>

            <div class="preview-table-container">
              <table class="preview-table">
                <thead>
                  <tr>
                    <th>用户名</th>
                    <th>邮箱</th>
                    <th>电话</th>
                    <th>性别</th>
                    <th>部门</th>
                    <th>角色</th>
                    <th>状态</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in previewData" :key="index">
                    <td>
                      <ElInput v-model="row.username" placeholder="请输入用户名" size="small" />
                    </td>
                    <td>
                      <ElInput v-model="row.email" placeholder="请输入邮箱" size="small" />
                    </td>
                    <td>
                      <ElInput v-model="row.phone" placeholder="请输入电话" size="small" />
                    </td>
                    <td>
                      <ElSelect
                        v-model="row.gender"
                        placeholder="请选择性别"
                        size="small"
                        style="width: 100%"
                      >
                        <ElOption label="男" value="1" />
                        <ElOption label="女" value="2" />
                      </ElSelect>
                    </td>
                    <td>
                      <ElInput
                        v-model="row.department_name"
                        placeholder="请输入部门"
                        size="small"
                      />
                    </td>
                    <td>
                      <ElInput v-model="row.role_names" placeholder="请输入角色" size="small" />
                    </td>
                    <td>
                      <ElRadioGroup v-model="row.status" size="small" class="status-radio-group">
                        <ElRadio label="1">启用</ElRadio>
                        <ElRadio label="0">禁用</ElRadio>
                      </ElRadioGroup>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <span class="dialog-footer flex justify-end">
          <ElButton @click="handleCancel">取消</ElButton>
          <!-- 步骤1 -->
          <template v-if="currentStep === 0">
            <ElButton type="primary" @click="handleNextStep" :disabled="fileList.length === 0">
              下一步
            </ElButton>
          </template>
          <!-- 步骤2 -->
          <template v-else-if="currentStep === 1">
            <ElButton @click="handlePrevStep">上一步</ElButton>
            <ElButton type="success" @click="handleSubmit">提交导入</ElButton>
          </template>
        </span>
      </template>
    </el-card>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'UserImportDialog' })

  import { ref, defineProps, defineEmits, watch } from 'vue'
  import { ElMessage, ElUpload } from 'element-plus'
  import { batchActionUserApi, batchImportUserApi } from '@/api/user'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const uploadRef = ref<InstanceType<typeof ElUpload> | null>(null)
  const currentStep = ref(0)
  const importType = ref<'创建' | '更新'>('创建')
  const fileList = ref<any[]>([])
  const previewData = ref<any[]>([])

  // 监听 dialogVisible 变化，向父组件传递
  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      // 重置表单
      if (!newVal) {
        resetForm()
      }
    }
  )

  // 文件变化处理
  const handleFileChange = (file: any) => {
    fileList.value = [file]
    previewData.value = []
  }

  // 上传前验证
  const beforeUpload = (file: File) => {
    const isXLSX =
      file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
      file.name.endsWith('.xlsx') ||
      file.name.endsWith('.csv')
    if (!isXLSX) {
      ElMessage.error('仅允许上传 xlsx 或 csv 格式文件')
      return false
    }

    const isLt5M = file.size / 1024 / 1024 < 5
    if (!isLt5M) {
      ElMessage.error('文件大小不能超过 5MB')
      return false
    }

    return true
  }

  // 下一步
  const handleNextStep = async () => {
    if (fileList.value.length === 0) {
      ElMessage.warning('请先选择有效的文件')
      return
    }

    const params = {
      import_type: importType.value,
      tag: 'file',
      file: fileList.value[0]
    }
    ElMessage.info('正在解析文件...,请稍等..')
    batchImportUserApi(params).then((res) => {
      if (res.code === 200) {
        console.log(res.data)
        previewData.value = res.data
        // ElMessage.success('文件预览成功')
        ElMessage.closeAll()
        ElMessage.success('文件解析成功')
        currentStep.value = 1
      } else {
        ElMessage.error('文件预览失败')
      }
    })
  }

  // 上一步
  const handlePrevStep = () => {
    currentStep.value = 0
  }

  // 提交导入
  const handleSubmit = async () => {
    try {
      // 模拟提交导入
      ElMessage.info('正在提交导入...')
      if (importType.value === '创建') {
        batchActionUserApi({
          actions: 'create',
          users: previewData.value
        })
          .then((res) => {
            if (res?.code === 200) {
              ElMessage.success(res?.msg)
              dialogVisible.value = false
              emit('success')
            } else {
              ElMessage.error(res?.message || '批量导入失败')
            }
          })
          .catch((error) => {
            console.error('批量导入失败:', error)
            ElMessage.error('批量导入失败')
          })
      }
    } catch (error) {
      console.error('导入失败:', error)
      ElMessage.error('导入失败，请重试')
    }
  }

  // 取消操作
  const handleCancel = () => {
    dialogVisible.value = false
  }

  // 下载模板
  const handleDownloadTemplate = (type: '创建' | '更新', kind: 'csv' | 'xlsx') => {
    // 模拟下载模板，实际项目中应替换为真实的模板下载链接
    const params = {
      import_type: type,
      tag: 'import_template',
      file_ext: kind
    }
    batchImportUserApi(params).then((res) => {
      if (res.code === 200) {
        window.open(res.url, '_blank')
        ElMessage.success('模板下载成功')
      } else {
        ElMessage.error('模板下载失败')
      }
    })
  }

  // 重置表单
  const resetForm = () => {
    currentStep.value = 0
    fileList.value = []
    previewData.value = []
    importType.value = '创建'
  }
</script>

<style scoped>
  .import-container {
    max-height: 500px;
    overflow-y: auto;
  }

  .preview-section {
    padding-top: 20px;
    margin-top: 20px;
    border-top: 1px solid #ebeef5;
  }

  .preview-table-container {
    max-height: 300px;
    overflow-y: auto;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
  }

  .preview-table {
    width: 100%;
    border-collapse: collapse;
    background-color: #fff;
  }

  .preview-table th,
  .preview-table td {
    padding: 8px 12px;
    font-size: 13px;
    text-align: left;
    border: 1px solid #dcdfe6;
  }

  .preview-table th {
    font-weight: 600;
    color: #303133;
    white-space: nowrap;
    background-color: #f5f7fa;
  }

  .preview-table td {
    color: #606266;
  }

  /* 自定义滚动条样式 */
  .import-container::-webkit-scrollbar,
  .preview-table-container::-webkit-scrollbar {
    width: 6px;
  }

  .import-container::-webkit-scrollbar-track,
  .preview-table-container::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 3px;
  }

  .import-container::-webkit-scrollbar-thumb,
  .preview-table-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
  }

  .import-container::-webkit-scrollbar-thumb:hover,
  .preview-table-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }
</style>
