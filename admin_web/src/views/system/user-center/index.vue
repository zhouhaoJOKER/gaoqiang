<!-- 个人中心页面 -->
<template>
  <div class="w-full h-full p-0 bg-transparent border-none shadow-none">
    <ArtTextScroll
      v-if="showTextScroll"
      :text="arterMsg"
      :speed="30"
      direction="right"
      showClose
      @close="handleClose"
    />
    <div class="relative flex-b mt-2.5 max-md:block max-md:mt-1">
      <div class="w-112 mr-5 max-md:w-full max-md:mr-0">
        <div class="art-card-sm relative p-9 pb-6 overflow-hidden text-center">
          <img class="absolute top-0 left-0 w-full h-50 object-cover" src="@imgs/user/bg.webp" />
          <div class="relative w-20 h-20 mt-30 mx-auto">
            <img
              class="z-10 w-full h-full object-cover border-2 border-white rounded-full"
              :src="avatarUrl"
            />
            <ArtSvgIcon
              icon="ri:image-edit-line"
              @click="triggerFileUpload"
              class="absolute bottom-0 right-0.5 z-100 w-8 h-8 p-0.5 bg-white border border-gray-200 rounded-full text-gray-300 cursor-pointer"
            />
          </div>
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            style="display: none"
            @change="handleFileChange"
          />
          <h2 class="mt-5 text-xl font-normal">{{ userInfo.userName }}</h2>
          <p class="mt-5 text-sm">专注于用户体验跟视觉设计</p>

          <div class="w-75 mx-auto mt-7.5 text-left">
            <div class="mt-2.5">
              <ArtSvgIcon icon="ri:mail-line" class="text-g-700" />
              <span class="ml-2 text-sm">jdkjjfnndf@mall.com</span>
            </div>
            <div class="mt-2.5">
              <ArtSvgIcon icon="ri:user-3-line" class="text-g-700" />
              <span class="ml-2 text-sm">交互专家</span>
            </div>
            <div class="mt-2.5">
              <ArtSvgIcon icon="ri:map-pin-line" class="text-g-700" />
              <span class="ml-2 text-sm">广东省深圳市</span>
            </div>
            <div class="mt-2.5">
              <ArtSvgIcon icon="ri:dribbble-fill" class="text-g-700" />
              <span class="ml-2 text-sm">字节跳动－某某平台部－UED</span>
            </div>
          </div>

          <div class="mt-10">
            <h3 class="text-sm font-medium">标签</h3>
            <div class="flex flex-wrap justify-center mt-3.5">
              <div
                v-for="item in lableList"
                :key="item"
                class="py-1 px-1.5 mr-2.5 mb-2.5 text-xs border border-g-300 rounded"
              >
                {{ item }}
              </div>
            </div>
          </div>
        </div>

        <div class="art-card-sm my-5">
          <ElForm class="box-border p-5" label-width="86px" label-position="top">
            <ElFormItem label="设置锁屏密码(默认:123)" prop="lock_password">
              <ElInput v-model="lock_password" type="password" />
            </ElFormItem>
            <div class="flex-c justify-end [&_.el-button]:!w-27.5">
              <ElButton type="primary" class="w-22.5" v-ripple @click="updateLockPwd">
                更新
              </ElButton>
            </div>
          </ElForm>
        </div>

        <div class="art-card-sm my-5">
          <h1 class="p-4 text-xl font-normal border-b border-g-300">更改密码</h1>

          <ElForm
            ref="pwdFormRef"
            :model="pwdForm"
            class="box-border p-5"
            label-width="86px"
            label-position="top"
            :rules="pwdRules"
          >
            <ElFormItem label="当前密码" prop="old_password">
              <ElInput
                v-model="pwdForm.old_password"
                type="password"
                :disabled="!isEditPwd"
                show-password
              />
            </ElFormItem>

            <ElFormItem label="新密码" prop="password">
              <ElInput
                v-model="pwdForm.password"
                type="password"
                :disabled="!isEditPwd"
                show-password
              />
            </ElFormItem>

            <div class="flex-c justify-end [&_.el-button]:!w-27.5">
              <ElButton type="primary" class="w-22.5" v-ripple @click="editPwd">
                {{ isEditPwd ? '保存' : '编辑' }}
              </ElButton>
            </div>
          </ElForm>
        </div>
      </div>
      <div class="flex-1 overflow-hidden max-md:w-full max-md:mt-3.5">
        <div class="art-card-sm">
          <h1 class="p-4 text-xl font-normal border-b border-g-300">基本设置</h1>

          <ElForm
            :model="form"
            class="box-border p-5 [&>.el-row_.el-form-item]:w-[calc(50%-10px)] [&>.el-row_.el-input]:w-full [&>.el-row_.el-select]:w-full"
            ref="ruleFormRef"
            :rules="rules"
            label-width="86px"
            label-position="top"
          >
            <ElRow>
              <ElFormItem label="姓名" prop="name">
                <ElInput v-model="form.name" :disabled="!isEdit" />
              </ElFormItem>
              <ElFormItem label="性别" prop="sex" class="ml-5">
                <ElSelect v-model="form.sex" placeholder="Select" :disabled="!isEdit">
                  <ElOption
                    v-for="item in options"
                    :key="item.value"
                    :label="item.label"
                    :value="item.value"
                  />
                </ElSelect>
              </ElFormItem>
            </ElRow>

            <ElRow>
              <ElFormItem label="昵称" prop="nickname">
                <ElInput v-model="form.nickname" :disabled="!isEdit" />
              </ElFormItem>
              <ElFormItem label="邮箱" prop="email" class="ml-5">
                <ElInput v-model="form.email" :disabled="!isEdit" />
              </ElFormItem>
            </ElRow>

            <ElRow>
              <ElFormItem label="手机" prop="phone">
                <ElInput v-model="form.phone" :disabled="!isEdit" />
              </ElFormItem>
              <ElFormItem label="地址" prop="address" class="ml-5">
                <ElInput v-model="form.address" :disabled="!isEdit" />
              </ElFormItem>
            </ElRow>

            <ElRow>
              <ElFormItem label="部门" prop="department">
                <el-select filterable v-model="form.department_id" placeholder="请选择部门">
                  <el-option
                    v-for="item in DEPT_LIST_DATA"
                    :key="item?.id || ''"
                    :label="item?.name || ''"
                    :value="item?.id || ''"
                    :disabled="!isEdit"
                  />
                </el-select>
              </ElFormItem>
              <ElFormItem label="角色" prop="role_id" class="ml-5">
                <ElSelect v-model="form.role_id" placeholder="请选择所属角色">
                  <ElOption
                    v-for="role in ROLE_LIST_DATA"
                    :key="role?.id || ''"
                    :value="role?.id || ''"
                    :label="role?.name || ''"
                    :disabled="!isEdit"
                  />
                </ElSelect>
              </ElFormItem>
            </ElRow>

            <ElRow>
              <ElFormItem label="个人介绍" prop="remark" class="h-32">
                <ElInput type="textarea" :rows="4" v-model="form.remark" :disabled="!isEdit" />
              </ElFormItem>
            </ElRow>

            <div class="flex-c justify-end [&_.el-button]:!w-27.5">
              <ElButton type="primary" class="w-22.5" v-ripple @click="editUser">
                {{ isEdit ? '保存' : '编辑' }}
              </ElButton>
            </div>
          </ElForm>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'UserCenter' })
  import { ref, computed, reactive, onMounted } from 'vue'
  import { useUserStore } from '@/store/modules/user'
  import type { FormInstance, FormRules } from 'element-plus'
  import { viewUserApi, updateUserApi, updateUserPwdApi } from '@/api/user'
  import { ElMessage } from 'element-plus'
  import CryptoJS from 'crypto-js'
  import { listPropertyApi } from '@/api/property'

  // 定义接口
  interface DepartmentItem {
    id?: string | number
    name?: string
  }

  interface RoleItem {
    id?: string | number
    name?: string
  }

  // 角色列表
  const ROLE_LIST_DATA = ref<RoleItem[]>([])
  // 部门列表
  const DEPT_LIST_DATA = ref<DepartmentItem[]>([])

  // 环境变量
  const ENCRYPT_KEY = import.meta.env.VITE_LOCK_ENCRYPT_KEY
  const userStore = useUserStore()
  const userInfo = computed(() => userStore.getUserInfo)

  const isEdit = ref(false)
  const isEditPwd = ref(false)
  const date = ref('')
  const avatarUrl = ref('')
  const pwdFormRef = ref<FormInstance>()
  const ruleFormRef = ref<FormInstance>()
  const fileInput = ref<HTMLInputElement>()
  const showTextScroll = ref(true)
  const arterMsg = ref('')
  const lock_password = ref('')

  /**
   * 用户信息表单
   */
  const form = reactive({
    id: '',
    nickname: '',
    name: '',
    email: '',
    phone: '',
    address: '',
    sex: '',
    department_id: '',
    role_id: '',
    remark: ''
  })

  /**
   * 密码修改表单
   */
  const pwdForm = reactive({
    id: '',
    password: '',
    old_password: ''
  })

  /**
   * 表单验证规则
   */
  const rules = reactive<FormRules>({
    nickname: [
      { required: true, message: '请输入昵称', trigger: 'blur' },
      { min: 2, max: 50, message: '长度在 2 到 30 个字符', trigger: 'blur' }
    ],
    name: [
      { required: true, message: '请输入昵称', trigger: 'blur' },
      { min: 2, max: 50, message: '长度在 2 到 30 个字符', trigger: 'blur' }
    ],
    email: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
    phone: [{ required: true, message: '请输入手机号码', trigger: 'blur' }],
    address: [{ required: true, message: '请输入地址', trigger: 'blur' }],
    sex: [{ required: true, message: '请选择性别', trigger: 'blur' }]
  })

  /**
   * 表单验证规则
   */
  const pwdRules = reactive<FormRules>({
    old_password: [
      { required: true, message: '请输入旧密码', trigger: 'blur' },
      { min: 6, message: '长度在 6 个字符以上', trigger: 'blur' }
    ],
    password: [
      { required: true, message: '请输入新密码', trigger: 'blur' },
      { min: 6, message: '长度在 6 个字符以上', trigger: 'blur' }
    ]
  })

  /**
   * 性别选项
   */
  const options = [
    { value: '1', label: '男' },
    { value: '2', label: '女' }
  ]

  /**
   * 用户标签列表
   */
  const lableList: Array<string> = ['专注设计', '很有想法', '辣~', '大长腿', '川妹子', '海纳百川']

  onMounted(async () => {
    getDate()
    try {
      const res = await listPropertyApi({
        tag: 'users'
      })
      // 将返回的res.roles数据赋值给ROLE_LIST_DATA
      if (res && res.roles) {
        ROLE_LIST_DATA.value = res.roles
        console.log('角色列表已加载:', ROLE_LIST_DATA.value)
      }
      if (res && res.departments) {
        DEPT_LIST_DATA.value = res.departments
        console.log('部门列表已加载:', ROLE_LIST_DATA.value)
      }
    } catch (error) {
      console.error('加载属性列表失败:', error)
    }
    try {
      // 获取路由参数中的id
      const id = userInfo.value.userId
      if (id) {
        // 调用API获取用户详情
        const res = await viewUserApi({ id })
        console.log(res)

        if (res && res.data) {
          // 填充表单数据
          Object.assign(form, {
            id: res.data.id || '',
            nickname: res.data.nickname || '',
            name: res.data.name || '',
            email: res.data.email || '',
            phone: res.data.phone || '',
            address: res.data.address || '',
            sex: res.data.sex || '',
            department_id: res.data.department_id || '',
            role_id: res.data.role_id || '',
            remark: res.data.remark || ''
          })
          const userInfo = res.data
          pwdForm.id = userInfo.id || ''
          // 设置头像URL
          if (res.data.avatar) {
            avatarUrl.value = res.data.avatar.url
          }
        }
      } else {
        ElMessage.warning('未找到用户ID参数')
      }
    } catch (error) {
      console.error('加载用户详情失败:', error)
      ElMessage.error('加载用户详情失败')
    }
  })

  // 触发文件上传
  const triggerFileUpload = () => {
    fileInput.value?.click()
  }

  // 处理文件选择
  const handleFileChange = (event: Event) => {
    const target = event.target as HTMLInputElement
    const file = target.files?.[0]

    if (file) {
      // 创建FormData用于上传
      const avatarData = new FormData()
      avatarData.append('avatar', file)

      // 显示上传中的提示
      ElMessage.info('头像上传中...')

      // 获取路由参数中的id
      const id = userInfo.value.userId

      // 调用更新用户信息的API上传头像
      updateUserApi(String(id), avatarData)
        .then((res) => {
          ElMessage.closeAll()
          if (res.success) {
            // 读取本地文件作为预览
            const reader = new FileReader()
            reader.onload = (e) => {
              avatarUrl.value = e.target?.result as string
            }
            reader.readAsDataURL(file)
            ElMessage.success('头像上传成功')
          } else {
            ElMessage.error(res.message || '头像上传失败')
          }
        })
        .catch((error) => {
          ElMessage.closeAll()
          console.error('头像上传失败:', error)
          ElMessage.error('头像上传失败')
        })
        .finally(() => {
          // 清空文件输入，允许再次选择相同文件
          if (target) {
            target.value = ''
          }
        })
    }
  }

  /**
   * 根据当前时间获取问候语
   */
  const getDate = () => {
    const h = new Date().getHours()

    if (h >= 6 && h < 9) date.value = '早上好'
    else if (h >= 9 && h < 11) date.value = '上午好'
    else if (h >= 11 && h < 13) date.value = '中午好'
    else if (h >= 13 && h < 18) date.value = '下午好'
    else if (h >= 18 && h < 24) date.value = '晚上好'
    else date.value = '很晚了，早点睡'

    arterMsg.value = date.value
  }

  /**
   * 切换用户信息编辑状态
   */
  const editUser = () => {
    console.log(isEdit.value)

    if (isEdit.value) {
      updateUserApi(form.id, form)
        .then((res) => {
          ElMessage.closeAll()
          if (res.success) {
            ElMessage.success('用户信息更新成功')
          } else {
            ElMessage.error(res.message || '用户信息更新失败')
          }
        })
        .catch((error) => {
          ElMessage.closeAll()
          console.error('用户信息更新失败:', error)
          ElMessage.error('用户信息更新失败')
        })
    }
    isEdit.value = !isEdit.value
  }

  /**
   * 切换密码编辑状态
   */
  const editPwd = async () => {
    isEditPwd.value = !isEditPwd.value
    if (!pwdFormRef.value) return

    await pwdFormRef.value.validate(async (valid) => {
      if (valid) {
        try {
          updateUserPwdApi(pwdForm)
            .then((res) => {
              console.log(res)
              if (res.success == 1) {
                ElMessage.success('密码更新成功')
                isEditPwd.value = !isEditPwd.value
                pwdForm.password = pwdForm.old_password = ''
              } else {
                ElMessage.error('密码更新失败：' + res.msg)
              }
            })
            .catch((error) => {
              ElMessage.closeAll()
              console.error('密码更新失败:', error)
              ElMessage.error('密码更新失败')
            })
        } catch {
          ElMessage.closeAll()
          ElMessage.error('接口请求失败')
        }
      }
    })
  }

  // 关闭滚动文字提示
  const handleClose = () => {
    showTextScroll.value = false
  }

  /**
   * 更新锁屏密码
   */
  const updateLockPwd = () => {
    if (!lock_password.value) {
      ElMessage.warning('请输入锁屏密码')
      return
    }
    try {
      // 设置一个默认的锁屏密码
      console.log(lock_password.value)
      console.log(ENCRYPT_KEY)
      const defaultPassword = CryptoJS.AES.encrypt(lock_password.value, ENCRYPT_KEY).toString()
      userStore.setLockPassword(defaultPassword)
      ElMessage.success('设置锁屏密码成功')
      lock_password.value = ''
    } catch {
      ElMessage.closeAll()
      ElMessage.error('接口请求失败')
    }
  }
</script>
