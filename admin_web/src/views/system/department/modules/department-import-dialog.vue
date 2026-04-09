<!-- 部门导入弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="导入部门"
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
            <label class="block text-sm font-medium text-gray-700 mb-2"
              >{{ importType }}模板下载</label
            >
            <ElLink type="primary" @click="handleDownloadTemplate(importType, 'csv')" class="mr-4">
              <i class="ri:ri-download-line"></i>
              CSV
            </ElLink>
            <ElLink type="primary" @click="handleDownloadTemplate(importType, 'xlsx')" class="mr-4">
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
                    <th>父级</th>
                    <th>部门名称</th>
                    <th>部门编码</th>
                    <th>负责人</th>
                    <th>排序</th>
                    <th>状态</th>
                    <th>备注</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in previewData" :key="index">
                    <td>
                      <ElTreeSelect
                        v-model="row.parent_id"
                        :data="departmentTreeData"
                        :props="treeSelectProps"
                        :expand-on-click-node="true"
                        :only-show-leaf-nodes="false"
                        placeholder="请选择上级部门"
                        check-strictly
                        filterable
                        clearable
                        required
                        size="small"
                        style="width: 100%"
                      />
                    </td>
                    <td>
                      <ElInput v-model="row.name" placeholder="请输入部门名称" size="small" />
                    </td>
                    <td>
                      <ElInput v-model="row.code" placeholder="请输入部门编码" size="small" />
                    </td>
                    <td>
                      <div class="flex gap-1">
                        <ElInput
                          v-model="row.manager_name"
                          placeholder="请选择负责人"
                          size="small"
                          style="flex: 1; cursor: pointer"
                          @click="showUserSelectDialog(index)"
                          @keyup.enter="showUserSelectDialog(index)"
                        />
                        <ElButton size="small" @click="clearManager(index)" v-if="row.manager_id">
                          清除
                        </ElButton>
                      </div>
                    </td>
                    <td>
                      <ElInput-number v-model="row.sort" :min="0" :step="1" size="small" />
                    </td>
                    <td>
                      <ElRadioGroup v-model="row.status" size="small" class="status-radio-group">
                        <ElRadio label="1">启用</ElRadio>
                        <ElRadio label="0">禁用</ElRadio>
                      </ElRadioGroup>
                    </td>
                    <td>
                      <ElInput
                        v-model="row.remark"
                        type="textarea"
                        placeholder="请输入备注"
                        size="small"
                        :rows="2"
                      />
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
            <ElButton type="primary" @click="handleNextStep" :disabled="fileList.length === 0"
              >下一步</ElButton
            >
          </template>
          <!-- 步骤2 -->
          <template v-else-if="currentStep === 1">
            <ElButton @click="handlePrevStep">上一步</ElButton>
            <ElButton type="success" @click="handleSubmit">提交导入</ElButton>
          </template>
        </span>
      </template>
    </el-card>

    <!-- 用户选择弹窗 -->
    <UserSelectDialog v-model="userSelectDialogVisible" @select="handleUserSelect" />
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'DepartmentImportDialog' })

  import { ref, defineProps, defineEmits, watch } from 'vue'
  import { ElMessage, ElUpload } from 'element-plus'
  import {
    batchActionDepartmentApi,
    batchImportDepartmentApi,
    listDepartmentTreeApi
  } from '@/api/department'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'

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
  const departmentTreeData = ref<any[]>([])
  const treeSelectProps = {
    value: 'id',
    label: 'name',
    children: 'children'
  }
  // 用户选择弹窗相关
  const userSelectDialogVisible = ref(false)
  const currentEditRowIndex = ref(-1)

  // 监听 dialogVisible 变化，向父组件传递
  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 获取部门树数据
  const getDepartmentTree = async () => {
    try {
      const res = await listDepartmentTreeApi({})
      let treeData = []
      if (res?.data) {
        if (Array.isArray(res.data)) {
          treeData = res.data
        } else if (typeof res.data === 'object') {
          treeData = res.data.departments || res.data.items || res.data.list || []
          if (!Array.isArray(treeData) && (res.data.id || res.data.children)) {
            treeData = [res.data]
          }
        }
      }
      departmentTreeData.value = treeData
    } catch (error) {
      console.error('获取部门树数据失败:', error)
      ElMessage.error('获取部门树数据失败')
      departmentTreeData.value = []
    }
  }

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      // 重置表单
      if (!newVal) {
        resetForm()
        getDepartmentTree()
      }
    }
  )

  // // 组件挂载时获取部门树数据
  // onMounted(() => {
  //   if (dialogVisible.value) {
  //     // getDepartmentTree()
  //   }
  // })
  // 下载模板
  const handleDownloadTemplate = (type: '创建' | '更新', kind: 'csv' | 'xlsx') => {
    // 模拟下载模板，实际项目中应替换为真实的模板下载链接
    // ElMessage.info('模板下载功能暂未实现')
    const params = {
      import_type: type,
      tag: 'import_template',
      file_ext: kind
    }
    batchImportDepartmentApi(params).then((res) => {
      if (res.code === 200) {
        window.open(res.url, '_blank')
        ElMessage.success('模板下载成功')
      } else {
        ElMessage.error('模板下载失败')
      }
    })
    // 示例：
  }

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
    batchImportDepartmentApi(params).then((res) => {
      if (res.code === 200) {
        console.log(res.data)
        previewData.value = res.data
        // ElMessage.success('文件预览成功')
        ElMessage.closeAll()
        ElMessage.success('文件解析成功')
        currentStep.value = 1
        // 此时加载部门树数据
        getDepartmentTree()
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
        batchActionDepartmentApi({
          actions: 'create',
          departments: previewData.value
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

  // 显示用户选择弹窗
  const showUserSelectDialog = (index: number) => {
    currentEditRowIndex.value = index
    userSelectDialogVisible.value = true
  }

  // 处理用户选择
  const handleUserSelect = (user: any) => {
    if (currentEditRowIndex.value >= 0) {
      previewData.value[currentEditRowIndex.value].manager_id = user.id
      previewData.value[currentEditRowIndex.value].manager_name = user.name
    }
  }

  // 清除负责人
  const clearManager = (index: number) => {
    previewData.value[index].manager_id = ''
    previewData.value[index].manager_name = ''
  }

  // 重置表单
  const resetForm = () => {
    currentStep.value = 0
    fileList.value = []
    previewData.value = []
    importType.value = '创建'
    userSelectDialogVisible.value = false
    currentEditRowIndex.value = -1
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
