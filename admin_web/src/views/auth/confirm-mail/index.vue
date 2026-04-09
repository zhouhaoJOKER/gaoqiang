<template>
  <!-- 加载中状态 -->
  <div v-if="loading" class="flex h-screen items-center justify-center bg-gray-50">
    <div class="text-center">
      <el-loading :fullscreen="false" text="正在激活账号..." />
      <p class="mt-4 text-gray-600">请稍候，正在处理您的请求...</p>
    </div>
  </div>

  <!-- 激活成功 -->
  <ArtResultPage
    v-else-if="activationStatus === 'success'"
    type="success"
    title="账号激活成功"
    message="账号激活成功，请使用新密码登录。"
    iconCode="ri:check-fill"
  >
    <template #extra>
      <el-button type="primary" @click="toLogin"> 前往登录 </el-button>
    </template>
  </ArtResultPage>

  <!-- 激活失败 -->
  <ArtResultPage
    v-else-if="activationStatus === 'error'"
    type="fail"
    title="账号激活失败"
    :message="errorMessage"
    iconCode="ri:close-circle-fill"
  >
    <template #extra>
      <el-button type="primary" @click="toLogin"> 前往登录 </el-button>
    </template>
  </ArtResultPage>
</template>

<script setup lang="ts">
  defineOptions({ name: 'ConfirmMail' })

  import { router } from '@/router'
  import { useRoute } from 'vue-router'
  import { ref, onMounted } from 'vue'
  import { confirmUserApi } from '@/api/auth'
  import { ElLoading, ElButton } from 'element-plus'

  const route = useRoute()
  const loading = ref(true)
  const activationStatus = ref<'loading' | 'success' | 'error'>('loading')
  const errorMessage = ref('账号激活链接无效或已过期')

  // 组件挂载时检查token参数并激活账号
  onMounted(async () => {
    const token = route.query.token as string
    if (!token) {
      loading.value = false
      activationStatus.value = 'error'
      errorMessage.value = '账号激活链接无效或已过期'
      return
    }

    try {
      const params = {
        token: token,
        tag: 'confirm_mail'
      }
      const res = await confirmUserApi(params)
      if (res.code === 200) {
        loading.value = false
        activationStatus.value = 'success'
        // 3秒后自动跳转到登录页面
        setTimeout(() => {
          router.push({ name: 'Login' })
        }, 3000)
      } else {
        loading.value = false
        activationStatus.value = 'error'
        errorMessage.value = res.msg || '账号激活失败，请联系客服'
      }
    } catch (error) {
      console.error('账号激活失败:', error)
      loading.value = false
      activationStatus.value = 'error'
      errorMessage.value = '账号激活失败，请联系客服'
    }
  })

  // 跳转到登录页面
  const toLogin = () => {
    router.push({ name: 'Login' })
  }
</script>
