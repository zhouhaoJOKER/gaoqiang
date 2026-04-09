<template>
  <div class="pt-5 art-page-view">
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>邮件设置</h4>
        </div>
      </div>
      <div class="mail-container">
        <el-form ref="formRef" :model="mailInfo" label-width="150px">
          <el-row :gutter="20">
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="支持电话" prop="support_phone">
                <el-input v-model="mailInfo.support_phone" placeholder="请输入支持电话" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="回复邮箱" prop="reply_email_to">
                <el-input v-model="mailInfo.reply_email_to" placeholder="请输入回复邮箱" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="发件人显示名称" prop="sender_display_name">
                <el-input
                  v-model="mailInfo.sender_display_name"
                  placeholder="请输入发件人显示名称"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="回复显示名称" prop="reply_display_name">
                <el-input v-model="mailInfo.reply_display_name" placeholder="请输入回复显示名称" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-divider />
          <el-row :gutter="20">
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP地址" prop="smtp_address">
                <el-input v-model="mailInfo.smtp_address" placeholder="请输入SMTP地址" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP端口" prop="smtp_port">
                <el-input v-model="mailInfo.smtp_port" placeholder="请输入SMTP端口" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP用户名" prop="smtp_user_name">
                <el-input v-model="mailInfo.smtp_user_name" placeholder="请输入SMTP用户名" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP密码" prop="smtp_password">
                <el-input
                  v-model="mailInfo.smtp_password"
                  type="password"
                  placeholder="请输入SMTP密码"
                />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP域名" prop="smtp_domain">
                <el-input v-model="mailInfo.smtp_domain" placeholder="请输入SMTP域名" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="SMTP认证方式" prop="smtp_authentication">
                <el-select v-model="mailInfo.smtp_authentication" placeholder="请选择SMTP认证方式">
                  <el-option label="Login" value="login" />
                  <el-option label="Plain" value="plain" />
                  <el-option label="CRAM-MD5" value="cram-md5" />
                </el-select>
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="启用SSL" prop="smtp_enable_ssl">
                <el-switch v-model="mailInfo.smtp_enable_ssl" />
              </el-form-item>
            </el-col>
            <el-col :xs="24" :sm="24" :md="24">
              <el-form-item class="flex justify-end">
                <el-button type="primary" @click="handleSubmit">保存</el-button>
                <el-button @click="handleReset">重置</el-button>
              </el-form-item>
            </el-col>
          </el-row>
          <el-divider />
          <el-row :gutter="20">
            <el-col :xs="24" :sm="24" :md="12">
              <el-form-item label="邮件测试" prop="test_email">
                <el-input v-model="test_email" placeholder="请输入测试邮箱">
                  <template #append>
                    <el-button
                      type="primary"
                      @click="handleTestEmail(test_email)"
                      :loading="testLoading"
                      >测试</el-button
                    >
                  </template>
                </el-input>
              </el-form-item>
            </el-col>
          </el-row>
        </el-form>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import type { FormInstance } from 'element-plus'
  import { ElMessage } from 'element-plus'
  import { createSettingApi, listSettingApi } from '@/api/setting'
  import { testApi } from '@/api/system-manage'

  const formRef = ref<FormInstance>()
  const testLoading = ref(false)
  const test_email = ref('')

  // 邮件配置信息
  const mailInfo = ref({
    support_phone: '1851605xxxx',
    reply_email_to: 'cxhyun@126.com',
    sender_display_name: 'iStar【客户服务】',
    reply_display_name: 'iStar【技术支持】',
    smtp_address: 'smtp.163.com',
    smtp_port: '465',
    smtp_user_name: 'cxhyun@163.com',
    smtp_password: 'mail_password',
    smtp_domain: '163.com',
    smtp_authentication: 'login',
    smtp_enable_ssl: true
  })

  const handleSubmit = async () => {
    await formRef.value?.validate()
    try {
      const res = await createSettingApi({ setting: mailInfo.value, tag: 'mail_info' })
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
  }

  // 邮件测试功能
  const handleTestEmail = async (email: string) => {
    if (!email) {
      ElMessage.warning('请输入测试邮箱')
      return
    }

    testLoading.value = true
    try {
      const res = await testApi({ email: test_email.value, tag: 'test_mail' })
      if (res && res.code === 200) {
        ElMessage.success('邮件发送测试成功')
      }
    } catch (error) {
      console.error('邮件测试失败:', error)
      ElMessage.error('邮件测试失败')
    } finally {
      testLoading.value = false
    }
  }

  // 初始化函数，获取邮件配置信息
  const initSettingInfo = async () => {
    try {
      const res = await listSettingApi({ tag: 'mail_info' })
      if (res && res.code === 200 && res.data.length > 0) {
        mailInfo.value = { ...mailInfo.value, ...res.data[0] }
      }
    } catch (error) {
      console.error('获取邮件设置信息失败:', error)
      ElMessage.error('获取邮件设置信息失败')
    }
  }

  // 组件挂载时初始化数据
  onMounted(() => {
    initSettingInfo()
  })

  defineOptions({ name: 'Mail' })
</script>

<style scoped>
  .mail-container {
    padding: 32px;
  }
</style>
