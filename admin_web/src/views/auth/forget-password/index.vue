<template>
  <div class="flex w-full h-screen">
    <LoginLeftView />

    <div class="relative flex-1">
      <AuthTopBar />

      <div class="auth-right-wrap">
        <div class="form">
          <h3 class="title">{{ $t('forgetPassword.title') }}</h3>
          <p class="sub-title">{{ $t('forgetPassword.subTitle') }}</p>
          <ElForm
            class="mt-7.5"
            ref="formRef"
            :model="formData"
            :rules="rules"
            label-position="top"
            :key="formKey"
          >
            <ElFormItem prop="email">
              <span class="input-label" v-if="showInputLabel">账号</span>
              <ElInput
                class="custom-height"
                v-model.trim="formData.email"
                :placeholder="$t('register.placeholder.email')"
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
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'ForgetPassword' })

  import { useI18n } from 'vue-i18n'
  import { fetchForgotPassword } from '@/api/auth'
  import { router } from '@/router'
  import { toJwt } from '@/utils'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { useSettingStore } from '@/store/modules/setting'
  import { getCssVar } from '@/utils/ui'

  interface FormData {
    email: string
    tag: string
  }

  const { t, locale } = useI18n()

  const formKey = ref(0)

  // 监听语言切换，重置表单
  watch(locale, () => {
    formKey.value++
  })

  const formRef = ref<FormInstance>()

  const formData = reactive<FormData>({
    email: '',
    tag: ''
  })

  // const router = useRouter()

  const settingStore = useSettingStore()
  const { isDark } = storeToRefs(settingStore)
  const dragVerify = ref()
  const isPassing = ref(false)
  const isClickPass = ref(false)
  const showInputLabel = ref(false)
  const REDIRECT_DELAY = 1000

  const loading = ref(false)

  /**
   * 验证邮箱格式
   * 确保邮箱格式符合标准
   */
  const validateEmail = (_rule: any, value: string, callback: (error?: Error) => void) => {
    if (!value) {
      callback(new Error(t('register.rule.emailRequired')))
      return
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    if (!emailRegex.test(value)) {
      callback(new Error(t('register.rule.emailInvalid')))
      return
    }

    callback()
  }

  const rules = computed<FormRules<FormData>>(() => ({
    email: [
      {
        required: true,
        validator: validateEmail,
        message: t('register.placeholder.email'),
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
      const params = {
        email: toJwt(formData.email),
        tag: 'email'
      }
      const res = await fetchForgotPassword(params)
      if (res.code === 200) {
        ElMessage.success('操作成功，请去邮箱查看重置密码的相关信息')
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
