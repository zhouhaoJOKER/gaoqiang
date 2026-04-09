<template>
  <div class="flex w-full h-screen">
    <LoginLeftView />

    <div class="relative flex-1">
      <AuthTopBar />

      <div class="auth-right-wrap">
        <div class="form">
          <h3 class="title">{{ $t('resetPassword.title') }}</h3>
          <p class="sub-title">{{ $t('resetPassword.subTitle') }}</p>
          <!-- 当token有效时显示表单 -->
          <div v-if="isTokenValid">
            <ElForm
              class="mt-7.5"
              ref="formRef"
              :model="formData"
              :rules="rules"
              label-position="top"
              :key="formKey"
            >
              <ElFormItem prop="password">
                <span class="input-label" v-if="showInputLabel">新密码</span>
                <ElInput
                  class="custom-height"
                  v-model="formData.password"
                  type="password"
                  :placeholder="$t('login.placeholder.password')"
                />
              </ElFormItem>

              <ElFormItem prop="confirmPassword">
                <span class="input-label" v-if="showInputLabel">确认新密码</span>
                <ElInput
                  class="custom-height"
                  v-model="formData.confirmPassword"
                  type="password"
                  :placeholder="$t('register.placeholder.confirmPassword')"
                />
              </ElFormItem>

              <!-- 推拽验证 -->
              <div class="relative pb-5 mt-6">
                <div
                  class="relative z-[2] overflow-hidden select-none rounded-lg border border-transparent tad-300"
                  :class="{ '!border-[#FF4E4F]': !isPassing && isClickPass }"
                >
                  <ArtDragVerify
                    ref="dragVerify"
                    v-model:value="isPassing"
                    :text="$t('login.sliderText')"
                    textColor="var(--art-gray-700)"
                    :successText="$t('login.sliderSuccessText')"
                    :progressBarBg="getCssVar('--el-color-primary')"
                    :background="isDark ? '#26272F' : '#F1F1F4'"
                    handlerBg="var(--default-box-color)"
                  />
                </div>
                <p
                  class="absolute top-2 z-[1] px-px mt-2 text-xs text-[#f56c6c] tad-300"
                  :class="{ 'translate-y-10': !isPassing && isClickPass }"
                >
                  {{ $t('login.placeholder.slider') }}
                </p>
              </div>

              <div style="margin-top: 15px">
                <ElButton
                  class="w-full custom-height"
                  type="primary"
                  @click="toRestSubmit"
                  :loading="loading"
                  v-ripple
                >
                  {{ $t('forgetPassword.submitBtnText') }}
                </ElButton>
              </div>

              <div style="margin-top: 15px">
                <ElButton class="w-full custom-height" plain @click="toLogin">
                  {{ $t('forgetPassword.backBtnText') }}
                </ElButton>
              </div>
            </ElForm>
          </div>

          <!-- 当token无效时显示提示信息 -->
          <div v-else class="mt-7.5 text-center">
            <div class="text-[#f56c6c] text-lg mb-4">
              <ElIcon class="text-4xl mb-2"><WarningFilled /></ElIcon>
              <p>重置密码链接无效或已过期</p>
              <p class="text-sm mt-2">系统将在3秒后自动跳转到登录页面</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'ForgetPassword' })

  import { ref, computed, watch, onMounted } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { resetPasswordAPI } from '@/api/auth'
  import { router } from '@/router'
  import { ElMessage, ElIcon } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { WarningFilled } from '@element-plus/icons-vue'
  import { useSettingStore } from '@/store/modules/setting'
  import { getCssVar } from '@/utils/ui'
  import { storeToRefs } from 'pinia'
  import { toJwt } from '@/utils'

  interface FormData {
    password: string
    confirmPassword: string
  }

  const { t, locale } = useI18n()
  const route = useRoute()

  const formKey = ref(0)

  // 监听语言切换，重置表单
  watch(locale, () => {
    formKey.value++
  })

  const formRef = ref<FormInstance>()

  const formData = reactive<FormData>({
    password: '',
    confirmPassword: ''
  })

  const settingStore = useSettingStore()
  const { isDark } = storeToRefs(settingStore)
  const dragVerify = ref()
  const isPassing = ref(false)
  const isClickPass = ref(false)
  const showInputLabel = ref(false)
  const REDIRECT_DELAY = 1000

  const loading = ref(false)
  const isTokenValid = ref(true)

  // 组件挂载时检查token参数
  onMounted(() => {
    const token = route.query.token as string
    if (!token) {
      isTokenValid.value = false
      ElMessage.error('重置密码链接无效或已过期')
      // 3秒后跳转到登录页面
      setTimeout(() => {
        router.push({ name: 'Login' })
      }, 3000)
    }
  })

  /**
   * 验证密码
   * 确保密码符合要求
   */
  const validatePassword = (_rule: any, value: string, callback: (error?: Error) => void) => {
    if (!value) {
      callback(new Error(t('login.rule.passwordRequired')))
      return
    }

    if (value.length < 6) {
      callback(new Error(t('login.rule.passwordMinLength')))
      return
    }

    callback()
  }

  /**
   * 验证确认密码
   * 确保两次输入的密码一致
   */
  const validateConfirmPassword = (
    _rule: any,
    value: string,
    callback: (error?: Error) => void
  ) => {
    if (!value) {
      callback(new Error('请再次输入密码'))
      return
    }

    if (value !== formData.password) {
      callback(new Error('两次输入的密码不一致'))
      return
    }

    callback()
  }

  const rules = computed<FormRules<FormData>>(() => ({
    password: [
      {
        required: true,
        validator: validatePassword,
        trigger: 'blur'
      }
    ],
    confirmPassword: [
      {
        required: true,
        validator: validateConfirmPassword,
        trigger: 'blur'
      }
    ]
  }))

  const toRestSubmit = async () => {
    if (!formRef.value) return

    // 拖拽验证（开关控制）
    if (!isPassing.value) {
      isClickPass.value = true
      return
    }
    try {
      await formRef.value.validate()
      loading.value = true
      // 获取URL参数中的id和token
      const token = route.query.token as string
      if (!token) {
        ElMessage.error('重置密码链接无效')
        loading.value = false
        return
      }
      const params = {
        token,
        password: toJwt(formData.password)
      }
      const res = await resetPasswordAPI(params)
      if (res.code === 200) {
        ElMessage.success('密码重置成功，请使用新密码登录')
        toLogin()
      }
    } catch (error) {
      console.error('表单验证失败:', error)
      loading.value = false
    }
  }

  /**
   * 跳转到登录页面
   */
  const toLogin = () => {
    setTimeout(() => {
      router.push({ name: 'Login' })
    }, REDIRECT_DELAY)
  }
</script>

<style scoped>
  @import '../login/style.css';
</style>
