<!-- 注册页面 -->
<template>
  <div class="flex w-full h-screen">
    <LoginLeftView />

    <div class="relative flex-1">
      <AuthTopBar />

      <div class="auth-right-wrap">
        <div class="form">
          <h3 class="title">{{ $t('register.title') }}</h3>
          <p class="sub-title">{{ $t('register.subTitle') }}</p>
          <ElForm
            class="mt-7.5"
            ref="formRef"
            :model="formData"
            :rules="rules"
            label-position="top"
            :key="formKey"
          >
            <ElFormItem prop="username">
              <ElInput
                class="custom-height"
                v-model.trim="formData.username"
                :placeholder="$t('register.placeholder.username')"
              />
            </ElFormItem>

            <ElFormItem prop="email">
              <ElInput
                class="custom-height"
                v-model.trim="formData.email"
                :placeholder="$t('register.placeholder.email')"
              />
            </ElFormItem>

            <ElFormItem prop="password">
              <ElInput
                class="custom-height"
                v-model.trim="formData.password"
                :placeholder="$t('register.placeholder.password')"
                type="password"
                autocomplete="off"
                show-password
              />
            </ElFormItem>

            <ElFormItem prop="confirmPassword">
              <ElInput
                class="custom-height"
                v-model.trim="formData.confirmPassword"
                :placeholder="$t('register.placeholder.confirmPassword')"
                type="password"
                autocomplete="off"
                @keyup.enter="toRegister"
                show-password
              />
            </ElFormItem>

            <ElFormItem prop="agreement">
              <ElCheckbox v-model="formData.agreement">
                {{ $t('register.agreeText') }}
                <RouterLink
                  style="color: var(--theme-color); text-decoration: none"
                  to="/privacy-policy"
                  >{{ $t('register.privacyPolicy') }}</RouterLink
                >
              </ElCheckbox>
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
                @click="toRegister"
                :loading="loading"
                v-ripple
              >
                {{ $t('register.submitBtnText') }}
              </ElButton>
            </div>

            <div class="mt-5 text-sm text-g-600">
              <span>{{ $t('register.hasAccount') }}</span>
              <RouterLink class="text-theme" :to="{ name: 'Login' }">{{
                $t('register.toLogin')
              }}</RouterLink>
            </div>
          </ElForm>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useI18n } from 'vue-i18n'
  import type { FormInstance, FormRules } from 'element-plus'
  import { fetchRegister } from '@/api/auth'
  import { toJwt } from '@/utils'
  import { useSettingStore } from '@/store/modules/setting'
  import { getCssVar } from '@/utils/ui'

  defineOptions({ name: 'Register' })

  interface RegisterForm {
    username: string
    email: string
    password: string
    confirmPassword: string
    agreement: boolean
  }

  const USERNAME_MIN_LENGTH = 3
  const USERNAME_MAX_LENGTH = 20
  const PASSWORD_MIN_LENGTH = 8
  const REDIRECT_DELAY = 1000

  const { t, locale } = useI18n()
  const router = useRouter()
  const formRef = ref<FormInstance>()

  const loading = ref(false)
  const formKey = ref(0)

  const settingStore = useSettingStore()
  const { isDark } = storeToRefs(settingStore)
  const dragVerify = ref()
  const isPassing = ref(false)
  const isClickPass = ref(false)

  // 监听语言切换，重置表单
  watch(locale, () => {
    formKey.value++
  })

  const formData = reactive<RegisterForm>({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    agreement: false
  })

  /**
   * 验证密码
   * 当密码输入后，如果确认密码已填写，则触发确认密码的验证
   */
  const validatePassword = (_rule: any, value: string, callback: (error?: Error) => void) => {
    if (!value) {
      callback(new Error(t('register.placeholder.password')))
      return
    }

    if (formData.confirmPassword) {
      formRef.value?.validateField('confirmPassword')
    }

    callback()
  }

  /**
   * 验证确认密码
   * 检查确认密码是否与密码一致
   */
  const validateConfirmPassword = (
    _rule: any,
    value: string,
    callback: (error?: Error) => void
  ) => {
    if (!value) {
      callback(new Error(t('register.rule.confirmPasswordRequired')))
      return
    }

    if (value !== formData.password) {
      callback(new Error(t('register.rule.passwordMismatch')))
      return
    }

    callback()
  }

  /**
   * 验证用户协议
   * 确保用户已勾选同意协议
   */
  const validateAgreement = (_rule: any, value: boolean, callback: (error?: Error) => void) => {
    if (!value) {
      callback(new Error(t('register.rule.agreementRequired')))
      return
    }
    callback()
  }

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

  const rules = computed<FormRules<RegisterForm>>(() => ({
    username: [
      { required: true, message: t('register.placeholder.username'), trigger: 'blur' },
      {
        min: USERNAME_MIN_LENGTH,
        max: USERNAME_MAX_LENGTH,
        message: t('register.rule.usernameLength'),
        trigger: 'blur'
      }
    ],
    password: [
      { required: true, validator: validatePassword, trigger: 'blur' },
      { min: PASSWORD_MIN_LENGTH, message: t('register.rule.passwordLength'), trigger: 'blur' }
    ],
    email: [
      {
        required: true,
        validator: validateEmail,
        message: t('register.placeholder.email'),
        trigger: 'blur'
      }
    ],
    confirmPassword: [{ required: true, validator: validateConfirmPassword, trigger: 'blur' }],
    agreement: [{ validator: validateAgreement, trigger: 'change' }]
  }))

  /**
   * 注册用户
   * 验证表单后提交注册请求
   */
  const toRegister = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()

      // 拖拽验证（开关控制）
      if (!isPassing.value) {
        isClickPass.value = true
        return
      }
      loading.value = true
      const params = {
        username: toJwt(formData.username),
        email: toJwt(formData.email),
        password: toJwt(formData.password)
      }
      const res = await fetchRegister(params)
      if (res.code === 200) {
        ElMessage.success('注册成功')
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
