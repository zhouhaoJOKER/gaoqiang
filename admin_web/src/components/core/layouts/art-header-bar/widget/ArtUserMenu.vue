<!-- 用户菜单 -->
<template>
  <ElPopover
    ref="userMenuPopover"
    placement="bottom-end"
    :width="180"
    :hide-after="0"
    :offset="10"
    trigger="hover"
    :show-arrow="false"
    popper-class="user-menu-popover"
    popper-style="padding: 5px 16px;"
  >
    <template #reference>
      <img
        class="size-8.5 mr-5 c-p rounded-full max-sm:w-6.5 max-sm:h-6.5 max-sm:mr-[16px]"
        :src="userInfo.avatar"
        alt="avatar"
      />
    </template>
    <template #default>
      <div class="pt-3">
        <div class="flex-c pb-1 px-0">
          <img
            class="w-10 h-10 mr-3 ml-0 overflow-hidden rounded-full float-left"
            :src="userInfo.avatar"
          />
          <div class="w-[calc(100%-60px)] h-full">
            <span class="block text-sm font-medium text-g-800 truncate">
              {{ userInfo.userName }}
            </span>
            <span class="block mt-0.5 text-xs text-g-500 truncate">
              {{ userInfo.email }}
            </span>
            <span v-if="currentCompanyName" class="block mt-0.5 text-xs text-primary-500 truncate">
              <ArtSvgIcon icon="ri:building-line" />{{ currentCompanyName }}
            </span>
          </div>
        </div>
        <ul class="py-4 mt-3 border-t border-g-300/80">
          <li class="btn-item" @click="goPage('/system/user-center')">
            <ArtSvgIcon icon="ri:user-3-line" />
            <span>{{ $t('topBar.user.userCenter') }}</span>
          </li>
          <li class="btn-item" @click="openCompanyDialog">
            <ArtSvgIcon icon="ri:building-line" />
            <span>切换公司</span>
          </li>
          <li class="btn-item" @click="lockScreen()">
            <ArtSvgIcon icon="ri:lock-line" />
            <span>{{ $t('topBar.user.lockScreen') }}</span>
          </li>
          <div class="w-full h-px my-2 bg-g-300/80"></div>
          <div class="log-out c-p" @click="loginOut">
            {{ $t('topBar.user.logout') }}
          </div>
        </ul>
      </div>
    </template>
  </ElPopover>
  <ElDialog
    v-model="companyDialogVisible"
    title="切换公司"
    width="520px"
    :close-on-click-modal="false"
  >
    <div class="mb-4">
      <ElInput v-model="companyKeyword" placeholder="请输入公司名称" clearable size="large" />
    </div>

    <div v-if="companyLoading" class="py-6 text-center text-g-500">加载中...</div>
    <div v-else>
      <div v-if="filteredCompanyList.length" class="border border-g-200 rounded-lg">
        <div class="flex items-center px-4 py-3 border-b border-g-200 text-g-700">
          <span class="inline-block w-2 h-2 mr-2 rounded-full bg-primary-500"></span>
          <span class="text-sm font-medium">当前公司：{{ currentCompanyName }}</span>
        </div>
        <ElScrollbar height="360px">
          <div class="py-2">
            <ElRadioGroup v-model="selectedCompanyId" class="w-full">
              <ElRadio
                v-for="item in filteredCompanyList"
                :key="item.id"
                :label="item.id"
                class="!m-0 w-full px-4 py-2 flex items-center hover:bg-g-100 cursor-pointer"
              >
                <span class="text-sm text-g-800">{{ item.name }}</span>
              </ElRadio>
            </ElRadioGroup>
          </div>
        </ElScrollbar>
      </div>
      <div v-else class="py-6 text-center text-g-400">暂无公司数据</div>
    </div>

    <template #footer>
      <div class="flex justify-end gap-3">
        <ElButton @click="companyDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="handleConfirmCompany">确定</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { useI18n } from 'vue-i18n'
  import { useRouter } from 'vue-router'
  import { ElMessageBox, ElMessage } from 'element-plus'
  import { listCompanyApi } from '@/api/company'
  import { useUserStore } from '@/store/modules/user'
  import { mittBus } from '@/utils/sys'
  import { updateUserApi } from '@/api/user'

  defineOptions({ name: 'ArtUserMenu' })

  const router = useRouter()
  const { t } = useI18n()
  const userStore = useUserStore()

  const { getUserInfo: userInfo } = storeToRefs(userStore)
  const userMenuPopover = ref()

  const companyDialogVisible = ref(false)
  const companyLoading = ref(false)
  const companyList = ref<any[]>([])
  const companyKeyword = ref('')
  const selectedCompanyId = ref<string | number | undefined>(undefined)
  const currentCompanyId = ref<string | number | undefined>(undefined)
  const currentCompanyName = ref<string>('')

  /**
   * 初始化当前公司信息（从本地或用户信息中）
   */
  const initCurrentCompany = () => {
    const localId = localStorage.getItem('currentCompanyId')
    const localName = localStorage.getItem('currentCompanyName')

    if (localId) {
      currentCompanyId.value = localId
    } else if ((userInfo.value as any).current_company_id) {
      currentCompanyId.value = (userInfo.value as any).current_company_id
    }

    if (localName) {
      currentCompanyName.value = localName
    } else if ((userInfo.value as any).current_company_name) {
      currentCompanyName.value = (userInfo.value as any).current_company_name
    }

    selectedCompanyId.value = currentCompanyId.value
  }

  initCurrentCompany()

  /**
   * 页面跳转
   * @param {string} path - 目标路径
   */
  const goPage = (path: string): void => {
    router.push(path)
  }

  /**
   * 打开锁屏功能
   */
  const lockScreen = (): void => {
    mittBus.emit('openLockScreen')
  }

  /**
   * 打开公司切换弹窗
   */
  const openCompanyDialog = async (): Promise<void> => {
    companyDialogVisible.value = true
    selectedCompanyId.value = currentCompanyId.value
    if (!companyList.value.length) {
      await fetchCompanyList()
    }
  }

  /**
   * 获取公司列表
   */
  const fetchCompanyList = async (): Promise<void> => {
    companyLoading.value = true
    try {
      const res = await listCompanyApi({ list: 1 })
      companyList.value = (res as any).data || []

      // 如果当前没有公司名称，但有 ID，则尝试从列表中反推名称
      if (!currentCompanyName.value && currentCompanyId.value) {
        const found = companyList.value.find(
          (item: any) => String(item.id) === String(currentCompanyId.value)
        )
        if (found) {
          currentCompanyName.value = found.name || ''
        }
      }
    } catch (error) {
      console.error('获取公司列表失败', error)
    } finally {
      companyLoading.value = false
    }
  }

  /**
   * 过滤后的公司列表
   */
  const filteredCompanyList = computed(() => {
    const keyword = companyKeyword.value.trim().toLowerCase()
    if (!keyword) return companyList.value
    return companyList.value.filter((item: any) => {
      const name = (item.name || '').toLowerCase()
      const abbr = (item.abbr || '').toLowerCase()
      return name.includes(keyword) || abbr.includes(keyword)
    })
  })

  /**
   * 选择公司
   */
  const handleConfirmCompany = async (): Promise<void> => {
    if (!selectedCompanyId.value) {
      ElMessage.warning('请选择公司')
      return
    }

    const company = companyList.value.find(
      (item: any) => String(item.id) === String(selectedCompanyId.value)
    )

    if (!company) {
      ElMessage.error('未找到选中的公司')
      return
    }

    try {
      const userId = userInfo.value.userId
      if (!userId) {
        ElMessage.error('用户信息异常，无法切换公司')
        return
      }

      // 更新后端用户当前公司
      await updateUserApi(String(userId), {
        current_company_id: selectedCompanyId.value
      })

      // 更新本地 store 和本地存储
      currentCompanyId.value = selectedCompanyId.value
      currentCompanyName.value = company.name || ''

      localStorage.setItem('currentCompanyId', String(currentCompanyId.value))
      localStorage.setItem('currentCompanyName', currentCompanyName.value)

      userStore.setUserInfo({
        ...(userInfo.value as any),
        current_company_id: currentCompanyId.value,
        current_company_name: currentCompanyName.value
      } as any)

      ElMessage.success('公司切换成功')
      companyDialogVisible.value = false
    } catch (error) {
      console.error('切换公司失败', error)
      ElMessage.error('切换公司失败')
    }
  }

  /**
   * 用户登出确认
   */
  const loginOut = (): void => {
    closeUserMenu()
    setTimeout(() => {
      ElMessageBox.confirm(t('common.logOutTips'), t('common.tips'), {
        confirmButtonText: t('common.confirm'),
        cancelButtonText: t('common.cancel'),
        customClass: 'login-out-dialog'
      }).then(() => {
        userStore.logOut()
      })
    }, 200)
  }

  /**
   * 关闭用户菜单弹出层
   */
  const closeUserMenu = (): void => {
    setTimeout(() => {
      userMenuPopover.value.hide()
    }, 100)
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  @layer components {
    .btn-item {
      @apply flex items-center p-2 mb-3 select-none rounded-md cursor-pointer last:mb-0;

      span {
        @apply text-sm;
      }

      .art-svg-icon {
        @apply mr-2 text-base;
      }

      &:hover {
        background-color: var(--art-gray-200);
      }
    }
  }

  .log-out {
    @apply py-1.5
    mt-5
    text-xs
    text-center
    border
    border-g-400
    rounded-md
    transition-all
    duration-200
    hover:shadow-xl;
  }
</style>
