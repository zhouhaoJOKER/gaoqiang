<!-- 登录页面 -->
<template>
  <div class="flex w-full h-screen">
    <LoginLeftView />

    <div class="relative flex-1 auth-right-shell">
      <AuthTopBar />

      <div class="auth-right-wrap">
        <div class="form login-form-surface">
          <h3 class="title">{{ $t('login.title') }}</h3>
          <p class="sub-title">{{ $t('login.subTitle') }}</p>
          <ElForm
            ref="formRef"
            :model="formData"
            :rules="rules"
            :key="formKey"
            @keyup.enter="handleSubmit"
            class="login-form-fields"
          >
            <ElFormItem prop="username">
              <ElInput
                class="custom-height"
                :placeholder="$t('login.placeholder.username')"
                v-model.trim="formData.username"
              />
            </ElFormItem>
            <ElFormItem prop="password">
              <ElInput
                class="custom-height"
                :placeholder="$t('login.placeholder.password')"
                v-model.trim="formData.password"
                type="password"
                autocomplete="off"
                show-password
              />
            </ElFormItem>

            <!-- 推拽验证 -->
            <div class="relative pb-5 mt-6" v-if="isCaptchaOpen">
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

            <div class="flex-cb mt-2 text-sm">
              <ElCheckbox v-model="formData.rememberPassword">{{
                $t('login.rememberPwd')
              }}</ElCheckbox>
              <RouterLink class="text-theme" :to="{ name: 'ForgetPassword' }">{{
                $t('login.forgetPwd')
              }}</RouterLink>
            </div>

            <div style="margin-top: 30px">
              <ElButton
                class="w-full custom-height"
                type="primary"
                @click="handleSubmit"
                :loading="loading"
                v-ripple
              >
                {{ $t('login.btnText') }}
              </ElButton>
            </div>

            <div class="mt-5 text-sm text-gray-600">
              <span>{{ $t('login.noAccount') }}</span>
              <RouterLink class="text-theme" :to="{ name: 'Register' }">{{
                $t('login.register')
              }}</RouterLink>
            </div>
          </ElForm>
        </div>

        <div class="login-preorder-hint">
          <RouterLink class="login-preorder-link" :to="{ name: 'Preorder' }">在线预购</RouterLink>
          <span class="login-preorder-sep">|</span>
          <span class="login-preorder-note">无需登录</span>
        </div>
      </div>

      <div class="login-footer">
        <p class="copyright text-center" style="margin-top: 15px; text-align: center">
          © {{ currentYear }}
          <RouterLink
            class="text-theme"
            :to="'/'"
            @click="handleDirectLink($event, systemInfo?.authorUrl, '_blank')"
          >
            {{ systemInfo?.authorName }}
          </RouterLink>
          &nbsp;
          <a :href="systemInfo?.authorUrl || '/'" target="_blank"></a>
          {{ systemInfo?.slogan }}&nbsp; {{ systemInfo?.versionCode }}<br />
          <RouterLink
            v-if="systemInfo?.icp"
            class="text-gary"
            :to="'/'"
            @click="handleDirectLink($event, 'http://beian.miit.gov.cn', '_blank')"
          >
            {{ systemInfo?.icp }}
          </RouterLink>
          &nbsp;

          <RouterLink
            v-if="systemInfo?.policeCode"
            class="text-gary gab"
            :to="'/'"
            @click="handleDirectLink($event, 'http://beian.miit.gov.cn', '_blank')"
          >
            {{ systemInfo?.policeCode }}
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  // import AppConfig from '@/config'
  import { useUserStore } from '@/store/modules/user'
  import { getCssVar } from '@/utils/ui'
  import { useI18n } from 'vue-i18n'
  import { HttpError } from '@/utils/http/error'
  import { fetchLogin, fetchGetUserInfo } from '@/api/auth'
  import { ElMessage, ElNotification, type FormInstance, type FormRules } from 'element-plus'
  import { useSettingStore } from '@/store/modules/setting'
  // import { useSystemInfo } from '@/hooks/core/useSyteminfo'
  import { storeToRefs } from 'pinia'
  import { toJwt } from '@/utils'

  defineOptions({ name: 'Login' })

  const settingStore = useSettingStore()
  const { isDark } = storeToRefs(settingStore)
  const { t, locale } = useI18n()
  const formKey = ref(0)
  // 已从 settingStore 中获取 systemInfo，无需重复导入

  // 监听语言切换，重置表单
  watch(locale, () => {
    formKey.value++
  })

  type AccountKey = 'super' | 'admin' | 'user'

  export interface Account {
    key: AccountKey
    label: string
    userName: string
    password: string
    roles: string[]
  }

  const accounts = computed<Account[]>(() => [
    {
      key: 'super',
      label: t('login.roles.super'),
      userName: 'user1',
      password: '123123123',
      roles: ['R_SUPER']
    },
    {
      key: 'admin',
      label: t('login.roles.admin'),
      userName: 'Admin',
      password: '123456',
      roles: ['R_ADMIN']
    },
    {
      key: 'user',
      label: t('login.roles.user'),
      userName: 'User',
      password: '123456',
      roles: ['R_USER']
    }
  ])

  const dragVerify = ref()

  const userStore = useUserStore()
  const router = useRouter()
  // const route = useRoute()
  const isPassing = ref(false)
  const isClickPass = ref(false)
  const isCaptchaOpen = ref(false)

  const { systemInfo } = storeToRefs(settingStore)
  // console.log('systemInfo in login:', systemInfo)

  // 获取当前年份
  const currentYear = computed(() => new Date().getFullYear())

  const formRef = ref<FormInstance>()

  const formData = reactive({
    account: '',
    username: '',
    password: '',
    rememberPassword: true
  })

  const rules = computed<FormRules>(() => ({
    username: [{ required: true, message: t('login.placeholder.username'), trigger: 'blur' }],
    password: [{ required: true, message: t('login.placeholder.password'), trigger: 'blur' }]
  }))

  const loading = ref(false)

  onMounted(() => {
    setupAccount('super')

    const info = systemInfo.value
    console.log('systemInfo:', info)

    // 滑块开关：后端返回 false 则关闭
    if (info && Object.prototype.hasOwnProperty.call(info, 'openCaptcha')) {
      isCaptchaOpen.value = info.openCaptcha !== false ? true : false
    }
    // try {
    //   const info = getSiteInfo()
    //   console.log("info")
    //   console.log(info.data)
    //   console.log("info")
    //   // 滑块开关：后端返回 false 则关闭
    //   if (info && Object.prototype.hasOwnProperty.call(info, 'openCaptcha')) {
    //     isCaptchaOpen.value = info.openCaptcha !== false ? true : false
    //   }
    //   if (info?.title) {
    //     systemName.value = info.title
    //     document.title = info.title
    //     // 存储到localStorage供其他组件使用
    //     localStorage.setItem('siteName', info.title)
    //   }
    // } catch {
    //   console.log('Load site info error')
    //   // 忽略站点信息加载错误，采用默认配置
    // }
  })
  const handleDirectLink = (event: any, url: any, target: any = '') => {
    // 阻止 RouterLink 的默认导航
    event.preventDefault()
    // 使用 window.location 进行跳转
    if (!url) return
    if (target === '_blank') {
      window.open(url, target)
    } else {
      window.location.href = url
    }
  }

  // 设置账号
  const setupAccount = (key: AccountKey) => {
    const selectedAccount = accounts.value.find((account: Account) => account.key === key)
    formData.account = key
    formData.username = selectedAccount?.userName ?? ''
    formData.password = selectedAccount?.password ?? ''
  }

  // 登录
  const handleSubmit = async () => {
    if (!formRef.value) return

    try {
      // 表单验证
      const valid = await formRef.value.validate()
      if (!valid) return

      // 拖拽验证（开关控制）
      if (isCaptchaOpen.value && !isPassing.value) {
        isClickPass.value = true
        return
      }

      loading.value = true

      // 登录请求
      const { username, password } = formData

      const { token } = await fetchLogin({
        name: toJwt(username),
        password: toJwt(password)
      })

      // 验证token
      if (!token) {
        throw new Error('Login failed - no token received')
      }

      // 存储token和用户信息
      // userStore.setToken(token, refreshToken)
      const res = await fetchGetUserInfo()
      let userInfo = res

      userStore.setUserInfo(userInfo)
      // 登录成功处理
      showLoginSuccessNotice(userInfo.userName)
      router.push('/')
    } catch (error) {
      // 处理 HttpError
      if (error instanceof HttpError) {
        // console.log(error.code)
      } else {
        // 处理非 HttpError

        ElMessage.error('登录失败，请稍后重试')
        console.error('[Login] Unexpected error:', error)
      }
    } finally {
      loading.value = false
      resetDragVerify()
    }
  }

  // 重置拖拽验证
  const resetDragVerify = () => {
    if (isCaptchaOpen.value === false) {
      console.log('isCaptchaOpen is false')
    } else {
      dragVerify.value.reset()
    }
  }

  // 登录成功提示
  const showLoginSuccessNotice = (username: string) => {
    setTimeout(() => {
      ElNotification({
        title: t('login.success.title'),
        type: 'success',
        duration: 2500,
        zIndex: 10000,
        message: `${t('login.success.message')}, ${username}!`
      })
    }, 1000)
  }
</script>

<style scoped>
  @import './style.css';
</style>

<style lang="scss" scoped>
  :deep(.el-select__wrapper) {
    height: 40px !important;
  }
</style>
