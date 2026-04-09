<template>
  <div class="pt-5 art-page-view">
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>系统信息</h4>
        </div>
      </div>
      <el-form ref="formRef" :model="systemInfo" label-width="120px">
        <el-row :gutter="20">
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统名称" prop="app_name">
              <el-input v-model="systemInfo.app_name" placeholder="请输入系统名称" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统地址" prop="host">
              <el-input v-model="systemInfo.host" placeholder="请输入系统地址" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统标题" prop="title_name">
              <el-input v-model="systemInfo.title_name" placeholder="请输入系统标题" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="是否开启验证码" prop="open_captcha">
              <el-switch v-model="systemInfo.open_captcha" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="开发者名称" prop="author_name">
              <el-input v-model="systemInfo.author_name" placeholder="请输入开发者名称" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="开发者地址" prop="author_url">
              <el-input v-model="systemInfo.author_url" placeholder="请输入开发者地址" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统Logo地址" prop="logo">
              <el-input v-model="systemInfo.logo" readonly placeholder="请输入系统Logo地址">
                <template #append>
                  <el-button type="primary" circle @click="logoUploadRef?.openDialog()">
                    <el-icon><UploadFilled /></el-icon>
                  </el-button>
                  <image-upload-dialog
                    ref="logoUploadRef"
                    @upload-success="(url) => (systemInfo.logo = url)"
                  />
                </template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统ICON地址" prop="favicon">
              <el-input v-model="systemInfo.favicon" readonly placeholder="请输入系统ICON地址">
                <template #append>
                  <el-button type="primary" circle @click="faviconUploadRef?.openDialog()">
                    <el-icon><UploadFilled /></el-icon>
                  </el-button>
                  <image-upload-dialog
                    ref="faviconUploadRef"
                    @upload-success="(url) => (systemInfo.favicon = url)"
                  />
                </template>
              </el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统标语" prop="titleName">
              <el-input v-model="systemInfo.slogan" placeholder="请输入系统标语" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="ICP 备案号" prop="icp">
              <el-input v-model="systemInfo.icp" placeholder="请输入ICP 备案号" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="公安备案号" prop="police_code">
              <el-input v-model="systemInfo.police_code" placeholder="请输入公安备案号" />
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="系统版本号" prop="version_code">
              <el-input v-model="systemInfo.version_code" placeholder="请输入系统版本号" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item>
              <el-button type="primary" @click="handleSubmit">保存</el-button>
              <el-button @click="handleReset">重置</el-button>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import type { FormInstance } from 'element-plus'
  import { ElMessage } from 'element-plus'
  import { UploadFilled } from '@element-plus/icons-vue'
  import { useSettingStore } from '@/store/modules/setting'
  import ImageUploadDialog from '@/components/ImageUploadDialog.vue'
  import { createSettingApi, listSettingApi } from '@/api/setting'

  const settingStore = useSettingStore()
  const systemInfo = ref<any>({})
  const formRef = ref<FormInstance>()
  const logoUploadRef = ref<InstanceType<typeof ImageUploadDialog> | null>(null)
  const faviconUploadRef = ref<InstanceType<typeof ImageUploadDialog> | null>(null)

  const handleSubmit = async () => {
    await formRef.value?.validate()
    try {
      console.log('systemInfo.value', systemInfo.value)
      const res = await createSettingApi({ setting: systemInfo.value, tag: 'base_info' })
      if (res && res.code === 200) {
        ElMessage.success('保存成功')

        settingStore.updateSystemInfo(systemInfo.value)
      }
    } catch (error) {
      console.error('保存数据失败:', error)
      ElMessage.error('保存数据失败')
    } finally {
      console.log('systemInfo.value', systemInfo.value)
    }
  }

  const handleReset = () => {
    formRef.value?.resetFields()
  }

  // 初始化函数，获取基础信息配置
  const initSettingInfo = async () => {
    try {
      const res = await listSettingApi({ tag: 'base_info' })
      if (res && res.code === 200) {
        systemInfo.value = { ...res.data[0] }
      }
    } catch (error) {
      console.error('获取设置信息失败:', error)
      ElMessage.error('获取设置信息失败')
    }
  }

  // 组件挂载时初始化数据
  onMounted(() => {
    initSettingInfo()
  })

  defineOptions({ name: 'Site' })
</script>

<style scoped>
  .site-container {
    width: 100%;
    height: 100%;
    padding: 32px;
  }
</style>
