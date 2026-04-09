<template>
  <div class="pt-5 art-page-view">
    <el-card>
      <div class="art-card-header">
        <div class="title">
          <h4>安全配置</h4>
        </div>
      </div>
      <el-form ref="formRef" :model="securityInfo" label-width="180px">
        <el-row :gutter="20">
          <!-- 默认密码 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="默认密码" prop="default_password">
              <el-input
                v-model="securityInfo.default_password"
                type="password"
                placeholder="请输入默认密码"
                show-password
              />
            </el-form-item>
          </el-col>

          <!-- 时区 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="时区" prop="time_zone">
              <el-select
                v-model="securityInfo.time_zone"
                placeholder="请选择时区"
                style="width: 100%"
              >
                <el-option
                  v-for="tz in timeZones"
                  :key="tz.value"
                  :label="tz.label"
                  :value="tz.value"
                />
              </el-select>
            </el-form-item>
          </el-col>

          <!-- 获取请求IP -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="获取请求IP" prop="get_request_ip">
              <el-input
                v-model="securityInfo.get_request_ip"
                placeholder="请输入获取请求IP的表达式"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 允许访问开始时间 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="允许访问开始时间" prop="allow_visit_start">
              <el-time-picker
                v-model="securityInfo.allow_visit_start"
                format="HH:mm:ss"
                value-format="HH:mm:ss"
                placeholder="选择开始时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 允许访问结束时间 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="允许访问结束时间" prop="allow_visit_end">
              <el-time-picker
                v-model="securityInfo.allow_visit_end"
                format="HH:mm:ss"
                value-format="HH:mm:ss"
                placeholder="选择结束时间"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- IP最大登录失败次数 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="IP最大登录失败次数" prop="ip_max_login_fail_num">
              <el-input-number
                v-model="securityInfo.ip_max_login_fail_num"
                :min="0"
                :max="100"
                placeholder="请输入IP最大登录失败次数"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 用户最大登录失败次数 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="用户最大登录失败次数" prop="user_max_login_fail_num">
              <el-input-number
                v-model="securityInfo.user_max_login_fail_num"
                :min="0"
                :max="100"
                placeholder="请输入用户最大登录失败次数"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 登录有效期（小时） -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="登录有效期（小时）" prop="login_validity_period_hour">
              <el-input-number
                v-model="securityInfo.login_validity_period_hour"
                :min="0"
                :max="8760"
                placeholder="请输入登录有效期（小时）"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 密码最小长度 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="密码最小长度" prop="password_min_length">
              <el-input-number
                v-model="securityInfo.password_min_length"
                :min="1"
                :max="100"
                placeholder="请输入密码最小长度"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 密码最大长度 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="密码最大长度" prop="password_max_length">
              <el-input-number
                v-model="securityInfo.password_max_length"
                :min="1"
                :max="100"
                placeholder="请输入密码最大长度"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>

          <!-- 开启日志 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="开启日志" prop="open_log">
              <el-switch v-model="securityInfo.open_log" />
            </el-form-item>
          </el-col>

          <!-- 开启安全 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="开启安全认证" prop="open_security_certificate">
              <el-switch v-model="securityInfo.open_security_certificate" />
            </el-form-item>
          </el-col>

          <!-- 开启校验位 -->
          <el-col :xs="24" :sm="24" :md="12" :lg="12" :xl="12">
            <el-form-item label="开启校验位" prop="open_check_digit">
              <el-switch v-model="securityInfo.open_check_digit" />
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
  import { createSettingApi, listSettingApi } from '@/api/setting'

  defineOptions({ name: 'Security' })

  const securityInfo = ref<any>({
    default_password: '',
    time_zone: 'Asia/Shanghai',
    get_request_ip: 'request.ip',
    allow_visit_start: '00:00:00',
    allow_visit_end: '23:59:59',
    ip_max_login_fail_num: 5,
    user_max_login_fail_num: 5,
    login_validity_period_hour: 24,
    password_min_length: 6,
    password_max_length: 20,
    open_log: false,
    open_security_certificate: false,
    open_check_digit: false
  })

  const formRef = ref<FormInstance>()

  // 时区选项
  const timeZones = [
    { label: 'UTC', value: 'UTC' },
    { label: '中国标准时间 (UTC+8)', value: 'Asia/Shanghai' },
    { label: '美国东部时间 (UTC-5)', value: 'America/New_York' },
    { label: '美国西部时间 (UTC-8)', value: 'America/Los_Angeles' },
    { label: '欧洲中部时间 (UTC+1)', value: 'Europe/Paris' },
    { label: '日本标准时间 (UTC+9)', value: 'Asia/Tokyo' },
    { label: '韩国标准时间 (UTC+9)', value: 'Asia/Seoul' },
    { label: '印度标准时间 (UTC+5:30)', value: 'Asia/Kolkata' },
    { label: '澳大利亚东部时间 (UTC+10)', value: 'Australia/Sydney' },
    { label: '英国标准时间 (UTC+0)', value: 'Europe/London' }
  ]

  const handleSubmit = async () => {
    await formRef.value?.validate()
    try {
      const res = await createSettingApi({ setting: securityInfo.value, tag: 'security_info' })
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

  // 初始化函数，获取安全配置信息
  const initSettingInfo = async () => {
    try {
      const res = await listSettingApi({ tag: 'security_info' })
      if (res && res.code === 200 && res.data && res.data.length > 0) {
        securityInfo.value = { ...securityInfo.value, ...res.data[0] }
      }
    } catch (error) {
      console.error('获取安全配置信息失败:', error)
      ElMessage.error('获取安全配置信息失败')
    }
  }

  // 组件挂载时初始化数据
  onMounted(() => {
    initSettingInfo()
  })
</script>

<style scoped>
  .security-container {
    width: 100%;
    height: 100%;
    padding: 32px;
  }
</style>
