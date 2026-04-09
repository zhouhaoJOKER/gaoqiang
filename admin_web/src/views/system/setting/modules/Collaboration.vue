<template>
  <div class="pt-5 art-page-view">
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>企业协同软件</h4>
        </div>
      </div>
      <el-form ref="formRef" :model="collaborationInfo" label-width="150px">
        <el-form-item label="" prop="collaboration">
          <el-radio-group v-model="collaborationInfo.collaboration" @change="handleSoftwareChange">
            <el-radio-button label="wechat_work">企业微信</el-radio-button>
            <el-radio-button label="dingtalk">钉钉</el-radio-button>
            <el-radio-button label="feishu">飞书</el-radio-button>
          </el-radio-group>
        </el-form-item>

        <!-- 企业微信配置 -->
        <el-collapse v-model="activeNames" accordion>
          <el-collapse-item
            title="企业微信配置"
            name="wechat_work"
            v-if="collaborationInfo.collaboration === 'wechat_work'"
          >
            <el-row :gutter="20">
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="企业ID" prop="wechat_work.corp_id">
                  <el-input
                    v-model="collaborationInfo.wechat_work.corp_id"
                    placeholder="请输入企业ID"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用ID" prop="wechat_work.agent_id">
                  <el-input
                    v-model="collaborationInfo.wechat_work.agent_id"
                    placeholder="请输入应用ID"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用密钥" prop="wechat_work.secret">
                  <el-input
                    v-model="collaborationInfo.wechat_work.secret"
                    type="password"
                    placeholder="请输入应用密钥"
                  />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>

          <!-- 钉钉配置 -->
          <el-collapse-item
            title="钉钉配置"
            name="dingtalk"
            v-if="collaborationInfo.collaboration === 'dingtalk'"
          >
            <el-row :gutter="20">
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="企业ID" prop="dingtalk.corp_id">
                  <el-input
                    v-model="collaborationInfo.dingtalk.corp_id"
                    placeholder="请输入企业ID"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用ID" prop="dingtalk.app_id">
                  <el-input
                    v-model="collaborationInfo.dingtalk.app_id"
                    placeholder="请输入应用ID"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用密钥" prop="dingtalk.app_secret">
                  <el-input
                    v-model="collaborationInfo.dingtalk.app_secret"
                    type="password"
                    placeholder="请输入应用密钥"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="内部应用ID" prop="dingtalk.inner_app_id">
                  <el-input
                    v-model="collaborationInfo.dingtalk.inner_app_id"
                    placeholder="请输入内部应用ID"
                  />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>

          <!-- 飞书配置 -->
          <el-collapse-item
            title="飞书配置"
            name="feishu"
            v-if="collaborationInfo.collaboration === 'feishu'"
          >
            <el-row :gutter="20">
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="企业ID" prop="feishu.corp_id">
                  <el-input v-model="collaborationInfo.feishu.corp_id" placeholder="请输入企业ID" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用ID" prop="feishu.app_id">
                  <el-input v-model="collaborationInfo.feishu.app_id" placeholder="请输入应用ID" />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="应用密钥" prop="feishu.app_secret">
                  <el-input
                    v-model="collaborationInfo.feishu.app_secret"
                    type="password"
                    placeholder="请输入应用密钥"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="24" :md="12">
                <el-form-item label="回调地址" prop="feishu.callback_url">
                  <el-input
                    v-model="collaborationInfo.feishu.callback_url"
                    placeholder="请输入回调地址"
                  />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
        </el-collapse>
        <br />

        <el-form-item v-if="collaborationInfo.collaboration">
          <el-button type="primary" @click="handleTestConnection" :loading="testLoading"
            >测试连接</el-button
          >
          <el-button type="success" @click="handleSyncUsers" :loading="syncLoading"
            >同步用户</el-button
          >
          <el-button type="primary" @click="handleSubmit">保存配置</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import type { FormInstance } from 'element-plus'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { createSettingApi, listSettingApi } from '@/api/setting'

  const formRef = ref<FormInstance>()
  const testLoading = ref(false)
  const syncLoading = ref(false)
  const activeNames = ref(['wechat_work'])

  // 协同软件配置信息
  const collaborationInfo = ref({
    collaboration: 'wechat_work',
    wechat_work: {
      corp_id: '',
      agent_id: '',
      secret: ''
    },
    dingtalk: {
      corp_id: '',
      app_id: '',
      app_secret: '',
      inner_app_id: ''
    },
    feishu: {
      corp_id: '',
      app_id: '',
      app_secret: '',
      callback_url: ''
    }
  })

  // 存储之前选择的软件类型，用于取消切换时恢复
  const previousSoftwareType = ref('wechat_work')

  const handleSoftwareChange = async (value: string | number | boolean | undefined) => {
    // 如果之前已经选择过软件类型，且新选择的类型与之前不同，则显示确认弹窗
    if (previousSoftwareType.value && previousSoftwareType.value !== value) {
      try {
        await ElMessageBox.confirm(
          '确定切换平台吗？注意：扫码登录及消息通知会调用切换后平台的配置，可能导致登录失败或消息接收异常，建议您谨慎操作！',
          '切换协同软件',
          {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
          }
        )
        // 用户确认后更新
        activeNames.value = [String(value)]
        previousSoftwareType.value = String(value)
      } catch {
        // 用户取消后恢复之前的选择
        collaborationInfo.value.collaboration = previousSoftwareType.value
      }
    } else {
      // 第一次选择或选择相同类型，直接更新
      activeNames.value = [String(value)]
      previousSoftwareType.value = String(value)
    }
  }

  const handleTestConnection = async () => {
    if (!collaborationInfo.value.collaboration) {
      ElMessage.warning('请先选择协同软件')
      return
    }

    testLoading.value = true
    try {
      // 调用测试连接接口
      // 实际项目中应该调用真实的测试接口
      await new Promise((resolve) => setTimeout(resolve, 1000))
      ElMessage.success('连接测试成功')
    } catch (error) {
      console.error('连接测试失败:', error)
      ElMessage.error('连接测试失败')
    } finally {
      testLoading.value = false
    }
  }

  const handleSyncUsers = async () => {
    if (!collaborationInfo.value.collaboration) {
      ElMessage.warning('请先选择协同软件')
      return
    }

    syncLoading.value = true
    try {
      // 调用同步用户接口
      // 实际项目中应该调用真实的同步接口
      await new Promise((resolve) => setTimeout(resolve, 1500))
      ElMessage.success('用户同步成功')
    } catch (error) {
      console.error('用户同步失败:', error)
      ElMessage.error('用户同步失败')
    } finally {
      syncLoading.value = false
    }
  }

  const handleSubmit = async () => {
    await formRef.value?.validate()
    try {
      const res = await createSettingApi({
        setting: collaborationInfo.value,
        tag: 'collaboration_info'
      })
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
    collaborationInfo.value = {
      collaboration: '',
      wechat_work: {
        corp_id: '',
        agent_id: '',
        secret: ''
      },
      dingtalk: {
        corp_id: '',
        app_id: '',
        app_secret: '',
        inner_app_id: ''
      },
      feishu: {
        corp_id: '',
        app_id: '',
        app_secret: '',
        callback_url: ''
      }
    }
  }

  // 初始化函数，获取协同软件配置信息
  const initSettingInfo = async () => {
    try {
      const res = await listSettingApi({ tag: 'collaboration_info' })
      if (res && res.code === 200 && res.data.length > 0) {
        collaborationInfo.value = { ...collaborationInfo.value, ...res.data[0] }
        if (collaborationInfo.value.collaboration) {
          activeNames.value = [collaborationInfo.value.collaboration]
          // 初始化之前选择的软件类型
          previousSoftwareType.value = collaborationInfo.value.collaboration
        }
      }
    } catch (error) {
      console.error('获取协同软件设置信息失败:', error)
      ElMessage.error('获取协同软件设置信息失败')
    }
  }

  // 组件挂载时初始化数据
  onMounted(() => {
    initSettingInfo()
  })

  defineOptions({ name: 'Collaboration' })
</script>

<style scoped>
  .collaboration-container {
    padding: 32px;
  }
</style>
