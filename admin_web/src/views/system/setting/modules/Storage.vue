<template>
  <div class="pt-5 art-page-view">
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>文件存储配置</h4>
        </div>
      </div>
      <el-form ref="formRef" :model="storageInfo" label-width="150px">
        <el-form-item label="存储类型" prop="storage_service">
          <el-radio-group v-model="storageInfo.storage_service" @change="handleStorageChange">
            <el-radio-button label="local">本地存储</el-radio-button>
            <el-radio-button label="s3">S3存储</el-radio-button>
          </el-radio-group>
        </el-form-item>

        <!-- S3存储配置 -->
        <el-collapse v-model="activeNames">
          <el-collapse-item
            title="S3存储配置"
            name="s3"
            v-if="storageInfo.storage_service === 's3'"
          >
            <el-row :gutter="20">
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="Endpoint" prop="s3.endpoint">
                  <el-input v-model="storageInfo.s3.endpoint" placeholder="请输入S3 Endpoint" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="Access Key" prop="s3.access_key_id">
                  <el-input v-model="storageInfo.s3.access_key_id" placeholder="请输入Access Key" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="Secret Key" prop="s3.secret_access_key">
                  <el-input
                    v-model="storageInfo.s3.secret_access_key"
                    type="password"
                    placeholder="请输入Secret Key"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="Bucket名称" prop="s3.bucket">
                  <el-input v-model="storageInfo.s3.bucket" placeholder="请输入Bucket名称" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="区域" prop="s3.region">
                  <el-input v-model="storageInfo.s3.region" placeholder="请输入区域" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="存储路径前缀" prop="s3.prefix">
                  <el-input v-model="storageInfo.s3.prefix" placeholder="请输入存储路径前缀" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>

          <el-collapse-item
            title="本地存储配置"
            name="local"
            v-if="storageInfo.storage_service === 'local'"
          >
            <el-row :gutter="20">
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="存储路径前缀" prop="storage_prefix">
                  <el-input v-model="storageInfo.storage_prefix" placeholder="请输入存储路径前缀" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
        </el-collapse>

        <br />

        <el-form-item>
          <el-button type="primary" @click="handleSubmit">保存配置</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <br />
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>文件测试</h4>
        </div>
      </div>
      <el-divider />
      <el-row :gutter="20">
        <el-col :xs="24" :sm="24" :md="24">
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeUpload"
            :file-list="fileList"
            accept="*"
            class="upload-demo"
          >
            <el-button type="primary">
              <el-icon class="el-icon--upload"><upload-filled /></el-icon>
              点击上传
            </el-button>
            <template #tip>
              <div class="el-upload__tip text-gray-500">测试文件单个大小不超过 5MB</div>
            </template>
          </el-upload>
          <el-divider />
          <el-button type="primary" @click="handleUploadTest">点击测试上传</el-button>
          <!-- 上传结果展示 -->
          <div v-if="uploadResult.visible" class="mt-4 bg-gray-100 p-2 rounded-md"
            >上传结果展示:</div
          >
          <el-alert
            v-if="uploadResult.visible"
            :title="uploadResult.title"
            :type="uploadResult.type"
            :closable="false"
            class="mt-4"
          />
        </el-col>
      </el-row>
    </el-card>

    <!-- 存储类型切换确认对话框 -->
    <el-dialog
      v-model="confirmDialog.visible"
      title="存储类型切换确认"
      width="400px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
    >
      <div class="dialog-content">
        <p
          >您正在尝试切换存储类型到：<strong>{{
            confirmDialog.targetType === 's3' ? 'S3存储' : '本地存储'
          }}</strong></p
        >
        <p class="mt-2 text-warning">切换存储类型可能会影响现有文件的访问方式，请谨慎操作！</p>
        <p class="mt-4 text-sm text-gray-500"
          >为了避免误操作，确认按钮将在
          <span class="text-red-500">{{ countDown }}</span> 秒后可用</p
        >
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="cancelStorageChange">取消</el-button>
          <el-button type="primary" @click="confirmStorageChange" :disabled="!canConfirm">
            确认切换（{{ countDown > 0 ? countDown + 's' : '' }}）
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import type { FormInstance, UploadInstance, UploadProps, UploadFile } from 'element-plus'
  import { ElMessage } from 'element-plus'
  import { UploadFilled } from '@element-plus/icons-vue'
  import { createSettingApi, listSettingApi } from '@/api/setting'
  import { uploadTestApi } from '@/api/system-manage'

  const formRef = ref<FormInstance>()
  const activeNames = ref(['local'])
  const uploadRef = ref<UploadInstance | null>(null)
  const currentFile = ref<File | null>(null)
  const fileList = ref<UploadFile[]>([])
  // 上传结果信息
  const uploadResult = ref({
    visible: false,
    title: '',
    type: 'success' as 'success' | 'error' | 'warning' | 'info'
  })
  // 存储类型切换确认对话框
  const confirmDialog = ref({
    visible: false,
    targetType: '' as string
  })
  // 倒计时相关
  const countDown = ref(10)
  const timer = ref<number | null>(null)
  const canConfirm = ref(false)

  // 存储配置信息
  const storageInfo = ref({
    storage_service: 'local',
    storage_prefix: '',
    s3: {
      endpoint: '',
      access_key_id: '',
      secret_access_key: '',
      bucket: '',
      region: '',
      prefix: ''
    }
  })

  // 存储之前选择的存储类型，用于取消切换时恢复
  const previousStorageType = ref('local')

  const handleStorageChange = (value: string | number | boolean | undefined) => {
    if (!value) return

    // 存储当前选择的存储类型，用于取消时恢复
    previousStorageType.value = storageInfo.value.storage_service

    // 保存目标类型并显示确认对话框
    confirmDialog.value.targetType = value as string
    confirmDialog.value.visible = true

    // 重置倒计时
    resetCountDown()
  }

  // 重置倒计时
  const resetCountDown = () => {
    // 清除之前的定时器
    if (timer.value) {
      clearInterval(timer.value)
      timer.value = null
    }

    // 重置倒计时和按钮状态
    countDown.value = 10
    canConfirm.value = false

    // 开始新的倒计时
    startCountDown()
  }

  // 开始倒计时
  const startCountDown = () => {
    timer.value = window.setInterval(() => {
      if (countDown.value > 1) {
        countDown.value--
      } else {
        // 倒计时结束，允许确认
        countDown.value = 0
        canConfirm.value = true
        if (timer.value) {
          clearInterval(timer.value)
          timer.value = null
        }
      }
    }, 1000)
  }

  // 确认切换存储类型
  const confirmStorageChange = () => {
    if (!canConfirm.value) return

    // 执行实际的存储类型切换
    const value = confirmDialog.value.targetType
    storageInfo.value.storage_service = value

    // 关闭对话框并清除定时器
    confirmDialog.value.visible = false
    if (timer.value) {
      clearInterval(timer.value)
      timer.value = null
    }
  }

  // 取消切换存储类型
  const cancelStorageChange = () => {
    // 恢复到之前选择的存储类型
    storageInfo.value.storage_service = previousStorageType.value

    // 关闭对话框并清除定时器
    confirmDialog.value.visible = false
    if (timer.value) {
      clearInterval(timer.value)
      timer.value = null
    }
  }

  // 处理文件选择
  const handleFileChange: UploadProps['onChange'] = (file, files) => {
    currentFile.value = file.raw as File
    fileList.value = files
  }

  const handleSubmit = async () => {
    await formRef.value?.validate()
    try {
      const res = await createSettingApi({ setting: storageInfo.value, tag: 'storage_info' })
      if (res && res.code === 200) {
        ElMessage.success('保存成功')
      }
    } catch (error) {
      console.error('保存数据失败:', error)
      ElMessage.error('保存数据失败')
    }
  }

  const handleReset = () => {
    formRef.value?.resetFields()
    storageInfo.value = {
      storage_service: 'local',
      storage_prefix: '',
      s3: {
        endpoint: '',
        access_key_id: '',
        secret_access_key: '',
        bucket: '',
        region: '',
        prefix: ''
      }
    }
  }

  // 测试文件上传
  const handleUploadTest = async () => {
    try {
      // 检查是否选择了文件
      if (!currentFile.value) {
        ElMessage.warning('请先选择要上传的文件')
        return
      }

      // 先保存配置，确保测试时使用最新的存储配置
      await formRef.value?.validate()
      await createSettingApi({ setting: storageInfo.value, tag: 'storage_info' })

      // 调用文件上传测试接口
      const formData = new FormData()
      formData.append('file', currentFile.value)
      const res = await uploadTestApi(formData)
      if (res && res.code === 200) {
        ElMessage.success('文件上传测试成功')
        // 显示上传成功的alert
        uploadResult.value = {
          visible: true,
          title: res.data,
          type: 'success'
        }
        // 清空已选择的文件
        resetUpload()
      } else {
        const errorMsg = '文件上传测试失败: ' + (res?.msg || '未知错误')
        ElMessage.error(errorMsg)
        // 显示上传失败的alert
        uploadResult.value = {
          visible: true,
          title: errorMsg,
          type: 'error'
        }
      }
    } catch (error) {
      console.error('文件上传测试失败:', error)
      const errorMsg = '文件上传测试失败，请检查配置是否正确'
      ElMessage.error(errorMsg)
      // 显示上传失败的alert
      uploadResult.value = {
        visible: true,
        title: errorMsg,
        type: 'error'
      }
    }
  }

  // 文件上传前的校验
  const beforeUpload: UploadProps['beforeUpload'] = (file) => {
    const isLt5M = file.size / 1024 / 1024 < 5

    if (!isLt5M) {
      ElMessage.error('上传文件大小不能超过 5MB')
      return false
    }
    return true
  }

  // 重置上传组件
  const resetUpload = () => {
    currentFile.value = null
    fileList.value = []
    // uploadResult.value.visible = false
    uploadRef.value?.clearFiles()
  }

  // 初始化函数，获取存储配置信息
  const initSettingInfo = async () => {
    try {
      const res = await listSettingApi({ tag: 'storage_info' })
      if (res && res.code === 200 && res.data.length > 0) {
        storageInfo.value = { ...storageInfo.value, ...res.data[0] }
        // 更新previousStorageType为当前加载的存储类型
        previousStorageType.value = storageInfo.value.storage_service
        if (storageInfo.value.storage_service === 's3') {
          activeNames.value = ['s3']
        }
      }
    } catch (error) {
      console.error('获取存储设置信息失败:', error)
      ElMessage.error('获取存储设置信息失败')
    }
  }

  // 组件挂载时初始化数据
  onMounted(() => {
    initSettingInfo()
  })

  defineOptions({ name: 'Storage' })
</script>

<style scoped>
  .storage-container {
    padding: 32px;
  }
</style>
