<!-- 角色导入弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="导入角色"
    width="700px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="role-import-container">
      <ElSteps :active="activeStep" align-center style="margin-bottom: 20px">
        <ElStep title="上传文件" description="上传角色Excel文件" />
        <ElStep title="数据预览" description="预览并确认数据" />
        <ElStep title="导入结果" description="查看导入结果" />
      </ElSteps>

      <!-- 步骤一：上传文件 -->
      <div v-if="activeStep === 0" class="upload-step">
        <ElUpload
          v-model:file-list="fileList"
          class="upload-excel"
          action=""
          :auto-upload="false"
          :on-change="handleFileChange"
          :before-upload="beforeUpload"
          accept=".xlsx,.csv"
          drag
        >
          <ElIcon class="el-icon--upload">
            <UploadFilled />
          </ElIcon>
          <div class="el-upload__text">点击上传或拖拽文件到此处</div>
          <template #tip>
            <div class="el-upload__tip"> 仅支持 .xlsx 或 .xls 格式，单个文件大小不超过 10MB </div>
          </template>
        </ElUpload>

        <div class="template-download" style="margin-top: 20px; text-align: center">
          <ElButton type="primary" plain @click="downloadTemplate">
            <template #icon>
              <Download />
            </template>
            下载导入模板
          </ElButton>
        </div>

        <div class="field-description" style="margin-top: 20px">
          <ElCollapse v-model="activeNames" accordion>
            <ElCollapseItem title="字段说明" name="1">
              <ul class="field-list" style="padding-left: 20px; margin-bottom: 0">
                <li style="margin-bottom: 8px">
                  <span class="required-field">* </span>
                  <strong>角色名称</strong>：必填，长度不超过50个字符
                </li>
                <li style="margin-bottom: 8px">
                  <span class="required-field">* </span>
                  <strong>角色编码</strong
                  >：必填，只能包含字母、数字和下划线，且必须以字母开头，长度不超过30个字符
                </li>
                <li style="margin-bottom: 8px">
                  <strong>排序</strong>：数字，非必填，默认为0，范围≥0
                </li>
                <li style="margin-bottom: 8px">
                  <strong>状态</strong>：非必填，默认为1（启用），可选值：0（禁用）、1（启用）
                </li>
                <li style="margin-bottom: 8px">
                  <strong>描述</strong>：非必填，字符串，不超过255个字符
                </li>
              </ul>
            </ElCollapseItem>
          </ElCollapse>
        </div>
      </div>

      <!-- 步骤二：数据预览 -->
      <div
        v-else-if="activeStep === 1"
        class="preview-step"
        v-loading="previewLoading"
        loading-text="正在解析文件..."
      >
        <div class="preview-info" style="margin-bottom: 15px">
          <ElTag type="info">共 {{ fileContent.length }} 条数据</ElTag>
          <ElTag v-if="hasError" type="danger">有 {{ errorCount }} 条数据有问题</ElTag>
        </div>

        <ElTable
          :data="fileContent"
          border
          style="width: 100%"
          header-row-class-name="preview-header-row"
          max-height="400px"
        >
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn prop="name" label="角色名称" show-overflow-tooltip>
            <template #default="scope">
              <div v-if="scope.row.error?.name" class="error-content">
                {{ scope.row.name || '(空)' }}
                <ElTooltip :content="scope.row.error.name" placement="top" :hide-after="3000">
                  <ElIcon color="#f56c6c" size="16">
                    <WarningFilled />
                  </ElIcon>
                </ElTooltip>
              </div>
              <span v-else>{{ scope.row.name || '(空)' }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="code" label="角色编码" show-overflow-tooltip>
            <template #default="scope">
              <div v-if="scope.row.error?.code" class="error-content">
                {{ scope.row.code || '(空)' }}
                <ElTooltip :content="scope.row.error.code" placement="top" :hide-after="3000">
                  <ElIcon color="#f56c6c" size="16">
                    <WarningFilled />
                  </ElIcon>
                </ElTooltip>
              </div>
              <span v-else>{{ scope.row.code || '(空)' }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="sort" label="排序" width="80">
            <template #default="scope">
              <div v-if="scope.row.error?.sort" class="error-content">
                {{ scope.row.sort || '(空)' }}
                <ElTooltip :content="scope.row.error.sort" placement="top" :hide-after="3000">
                  <ElIcon color="#f56c6c" size="16">
                    <WarningFilled />
                  </ElIcon>
                </ElTooltip>
              </div>
              <span v-else>{{ scope.row.sort || 0 }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="status" label="状态" width="80">
            <template #default="scope">
              <ElTag v-if="scope.row.status === 1" type="success">启用</ElTag>
              <ElTag v-else-if="scope.row.status === 0" type="danger">禁用</ElTag>
              <span v-else class="text-gray">默认启用</span>
            </template>
          </ElTableColumn>
          <ElTableColumn prop="description" label="描述" show-overflow-tooltip>
            <template #default="scope">
              <span>{{ scope.row.description || '(空)' }}</span>
            </template>
          </ElTableColumn>
        </ElTable>
      </div>

      <!-- 步骤三：导入结果 -->
      <div
        v-else-if="activeStep === 2"
        class="result-step"
        v-loading="importLoading"
        loading-text="正在导入数据..."
      >
        <div v-if="importResult" class="result-content">
          <div class="result-header" style="margin-bottom: 20px">
            <ElEmpty v-if="importResult.total === 0" description="未导入任何数据" />
            <ElResult
              v-else-if="importResult.successCount === importResult.total"
              :icon="'success'"
              title="导入成功"
              sub-title="全部数据导入成功"
            />
            <ElResult
              v-else
              :icon="'warning'"
              title="部分导入成功"
              sub-title="部分数据导入失败，请查看下方失败原因"
            />
          </div>

          <div class="result-stats" style="margin-bottom: 20px">
            <ElStatistic title="总记录数" :value="importResult.total" />
            <ElStatistic title="成功记录" :value="importResult.successCount" />
            <ElStatistic title="失败记录" :value="importResult.failCount" />
          </div>

          <ElTable
            v-if="importResult.failData.length > 0"
            :data="importResult.failData"
            border
            style="width: 100%"
            max-height="300px"
          >
            <ElTableColumn type="index" label="序号" width="60" />
            <ElTableColumn prop="name" label="角色名称" show-overflow-tooltip />
            <ElTableColumn prop="code" label="角色编码" show-overflow-tooltip />
            <ElTableColumn prop="error" label="失败原因" min-width="200" show-overflow-tooltip />
          </ElTable>
        </div>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton v-if="activeStep === 0" @click="handleCancel">取消</ElButton>
        <ElButton v-if="activeStep === 1" @click="goBack">上一步</ElButton>
        <ElButton v-if="activeStep === 2" @click="handleCancel">关闭</ElButton>

        <ElButton
          v-if="activeStep === 0"
          type="primary"
          :disabled="!canPreview"
          @click="previewData"
          >下一步</ElButton
        >
        <ElButton
          v-if="activeStep === 1"
          type="primary"
          :loading="importLoading"
          @click="startImport"
          >开始导入</ElButton
        >
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'RoleImportDialog' })

  import { ref, defineProps, defineEmits, watch, computed } from 'vue'
  import { ElMessage } from 'element-plus'
  import { UploadFilled, Download, WarningFilled } from '@element-plus/icons-vue'
  import { batchImportRoleApi } from '@/api/role'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  // 类型定义
  interface FileContentItem {
    name?: string
    code?: string
    error?: Record<string, string>
    [key: string]: any
  }

  interface ImportResultData {
    total: number
    successCount: number
    failCount: number
    failData: any[]
  }

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const fileList = ref<any[]>([])
  const activeStep = ref(0)
  const activeNames = ref(['1'])
  const fileContent = ref<FileContentItem[]>([])
  const previewLoading = ref(false)
  const importLoading = ref(false)
  const importResult = ref<ImportResultData | null>(null)
  const currentFile = ref<File | null>(null)

  // 计算属性
  const canPreview = computed(() => fileList.value.length > 0)
  const hasError = computed(() =>
    fileContent.value.some((item) => Object.keys(item.error || {}).length > 0)
  )
  const errorCount = computed(
    () => fileContent.value.filter((item) => Object.keys(item.error || {}).length > 0).length
  )

  // 监听 dialogVisible 变化，向父组件传递
  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (!newVal) {
        resetForm()
      }
    }
  )

  // 文件格式校验
  const beforeUpload = (file: File) => {
    const fileType = file.name.split('.').pop()
    const isExcel = ['xlsx', 'xls'].includes(fileType || '')
    if (!isExcel) {
      ElMessage.error('只能上传 .xlsx 或 .xls 格式的文件')
      return false
    }

    const isLt10M = file.size / 1024 / 1024 <= 10
    if (!isLt10M) {
      ElMessage.error('文件大小不能超过 10MB')
      return false
    }

    return true
  }

  // 处理文件选择变化
  const handleFileChange = (file: any, list: any[]) => {
    fileList.value = list
    currentFile.value = file.raw
  }

  // 下载模板
  const downloadTemplate = async () => {
    try {
      // 使用batchImportRoleApi下载模板
      const params = {
        import_type: 'create',
        tag: 'import_template',
        file_ext: 'xlsx'
      }
      const res = await batchImportRoleApi(params)
      if (res?.code === 200) {
        window.open(res.url, '_blank')
        ElMessage.success('模板下载成功')
      } else {
        ElMessage.error(res?.message || '模板下载失败')
      }
    } catch (error) {
      console.error('模板下载失败:', error)
      ElMessage.error('模板下载失败')
    }
  }

  // 预览数据
  const previewData = async () => {
    if (!currentFile.value) {
      ElMessage.warning('请先选择文件')
      return
    }

    previewLoading.value = true
    try {
      // 调用预览接口
      const params = {
        import_type: 'create',
        tag: 'file',
        file: currentFile.value
      }
      const res = await batchImportRoleApi(params)
      if (res?.code === 200) {
        fileContent.value = res.data || []
        // 初始化每条数据的error对象
        fileContent.value.forEach((item) => {
          if (!item.error) {
            item.error = {}
          }
        })
        activeStep.value = 1
      } else {
        ElMessage.error(res?.message || '解析文件失败')
      }
    } catch (error) {
      console.error('解析文件失败:', error)
      ElMessage.error('解析文件失败')
    } finally {
      previewLoading.value = false
    }
  }

  // 开始导入
  const startImport = async () => {
    if (fileContent.value.length === 0) {
      ElMessage.warning('没有要导入的数据')
      return
    }

    importLoading.value = true
    try {
      // 调用导入接口
      const params = {
        import_type: 'create',
        tag: 'import',
        file: currentFile.value
      }
      const res = await batchImportRoleApi(params)
      if (res?.code === 200) {
        importResult.value = res.data || {
          total: 0,
          successCount: 0,
          failCount: 0,
          failData: []
        }
        activeStep.value = 2
        // 如果全部成功，触发success事件
        if (importResult.value && importResult.value.successCount === importResult.value.total) {
          emit('success')
        }
      } else {
        ElMessage.error(res?.message || '导入失败')
      }
    } catch (error) {
      console.error('导入失败:', error)
      ElMessage.error('导入失败')
    } finally {
      importLoading.value = false
    }
  }

  // 返回上一步
  const goBack = () => {
    activeStep.value = 0
  }

  // 取消操作
  const handleCancel = () => {
    dialogVisible.value = false
  }

  // 重置表单
  const resetForm = () => {
    activeStep.value = 0
    fileList.value = []
    fileContent.value = []
    importResult.value = null
    currentFile.value = null
  }
</script>

<style scoped>
  .role-import-container {
    padding: 10px 0;
  }

  .upload-excel {
    padding: 20px;
    text-align: center;
    border: 1px dashed #dcdfe6;
    border-radius: 6px;
  }

  .preview-header-row {
    font-weight: bold;
    background-color: #f5f7fa;
  }

  .error-content {
    display: flex;
    align-items: center;
    color: #f56c6c;
  }

  .required-field {
    color: #f56c6c;
  }

  .text-gray {
    color: #909399;
  }

  .result-stats {
    display: flex;
    justify-content: space-around;
  }

  .result-content {
    text-align: center;
  }
</style>
