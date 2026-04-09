<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogType === 'add' ? '添加用户' : '编辑用户'"
    width="600px"
    :close-on-click-modal="false"
    :close-on-press-escape="true"
  >
    <ElForm ref="formRef" :model="formData" :rules="rules" label-width="80px">
      <ElFormItem label="用户名" prop="name">
        <ElInput v-model="formData.name" @blur="validateUserName" />
      </ElFormItem>
      <ElFormItem label="密码" prop="password">
        <ElInput v-model="formData.password" type="password" show-password />
      </ElFormItem>
      <ElFormItem label="邮箱" prop="email">
        <ElInput v-model="formData.email" />
      </ElFormItem>
      <ElFormItem label="手机号" prop="phone">
        <ElInput v-model="formData.phone" />
      </ElFormItem>
      <ElFormItem label="性别" prop="sex">
        <ElSelect v-model="formData.sex">
          <ElOption label="男" value="男" />
          <ElOption label="女" value="女" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="部门" prop="department">
        <el-select filterable v-model="formData.department_id" placeholder="请选择部门">
          <el-option
            v-for="item in deptList"
            :key="item?.id || 0"
            :label="item?.name || ''"
            :value="item?.id || 0"
          />
        </el-select>
      </ElFormItem>
      <ElFormItem label="角色" prop="role_id">
        <ElSelect v-model="formData.role_id" placeholder="请选择所属角色">
          <ElOption
            v-for="role in roleList"
            :key="role?.id || 0"
            :value="role?.id || 0"
            :label="role?.name || ''"
          />
        </ElSelect>
      </ElFormItem>
    </ElForm>
    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="dialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, reactive, watch, nextTick, onMounted } from 'vue'
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElMessage } from 'element-plus'
  import { searchUserApi, createUserApi, updateUserApi } from '@/api/user'
  import { listPropertyApi } from '@/api/property'

  interface DepartmentItem {
    id?: string | number
    name?: string
  }

  interface RoleItem {
    id?: string | number
    name?: string
  }

  const ROLE_LIST_DATA = ref<RoleItem[]>([])
  const DEPT_LIST_DATA = ref<DepartmentItem[]>([])
  // 在页面加载时调用listPropertyApi
  onMounted(async () => {
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
  })

  interface Props {
    visible: boolean
    type: string
    userData?: any
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit'): void
    // // 添加新的emit事件类型
    (e: 'addData', data: any): void
    (e: 'updateData', data: any): void
  }
  const props = defineProps<Props>()

  // const props = withDefaults(defineProps<Props>(), {
  //   visible: false,
  //   type: 'add',
  //   userData: () => ({})
  // })

  const emit = defineEmits<Emits>()
  // 角色列表数据
  const roleList = ref(ROLE_LIST_DATA)
  // 部门列表数据
  const deptList = ref(DEPT_LIST_DATA)

  // 对话框显示控制
  const dialogVisible = computed({
    get: () => props.visible,
    set: (value) => emit('update:visible', value)
  })

  const dialogType = computed(() => props.type)

  // 表单实例
  const formRef = ref<FormInstance>()

  //随机生成6位字符的邮箱，并赋值给新建用户的email字段

  const randomStr = () => {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789'
    let str = ''
    for (let i = 0; i < 6; i++) {
      str += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return str
  }
  const randomEmail = () => {
    let email = randomStr()
    return email + '@qq.com'
  }

  // 表单数据
  const formData = reactive({
    id: '',
    name: '',
    phone: '',
    password: '',
    email: '',
    sex: '男',
    department_id: '',
    role_id: '',
    status: ''
  })

  // 表单验证规则
  const rules: FormRules = {
    name: [
      { required: true, message: '请输入用户名', trigger: 'blur' },
      { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
    ],
    phone: [
      { required: false, message: '请输入手机号', trigger: 'blur' },
      { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
    ],
    sex: [{ required: true, message: '请选择性别', trigger: 'blur' }],
    role_id: [{ required: true, message: '请选择角色', trigger: 'blur' }]
  }

  // 校验用户名唯一性
  const validateUserName = async () => {
    if (!formData.name.trim()) return
    try {
      // 注意：HTTP请求库会自动解包返回res.data.data
      const res = await searchUserApi({
        key: 'name',
        value: formData.name.trim()
      })
      // 现在res就是data里面的数据，直接检查success
      if (res && res.success !== 1) {
        // 如果success不等于1，表示用户名已存在
        ElMessage.error('用户名已存在')
        formData.name = '' // 清空输入
        formRef.value?.validateField('name') // 触发表单验证
      }
    } catch (error) {
      console.error('校验用户名失败:', error)
      formData.name = '' // 清空输入
      formRef.value?.validateField('name') // 触发表单验证
    }
  }

  // 初始化表单数据
  const initFormData = () => {
    const isEdit = props.type === 'edit' && props.userData
    const row = props.userData

    Object.assign(formData, {
      id: isEdit ? row.id || '' : '',
      name: isEdit ? row.name || '' : '',
      phone: isEdit ? row.phone || '' : '',
      sex: isEdit ? row.sex || '男' : '男',
      department_id: isEdit ? row.department_id || '' : '',
      password: isEdit ? row.password || '' : randomStr(),
      email: isEdit ? row.email || '' : randomEmail(),
      role_id: isEdit ? row.role_id || '' : '',
      status: isEdit ? row.status || '' : ''
    })
  }

  // 统一监听对话框状态变化
  watch(
    () => [props.visible, props.type, props.userData],
    ([visible]) => {
      if (visible) {
        initFormData()
        nextTick(() => {
          formRef.value?.clearValidate()
        })
      }
    },
    { immediate: true }
  )

  // 提交表单
  const handleSubmit = async () => {
    if (!formRef.value) return

    await formRef.value.validate(async (valid) => {
      if (valid) {
        console.log(formData)
        try {
          await formRef.value?.validate()

          // 准备提交的数据
          const submitData = {
            ...formData,
            role_id: formData.role_id || '',
            status: formData.status ? 1 : 0
          }

          if (props.type === 'add') {
            // 添加用户逻辑
            const res = await createUserApi(submitData)
            console.log('添加用户结果:', res)

            if (res?.success === 1) {
              // 创建成功，发射addData事件，传递新用户数据
              const newUserData = {
                ...submitData,
                id: res.id, // 使用API返回的ID或当前时间戳
                createTime: new Date().toISOString(),
                updateTime: new Date().toISOString()
              }
              emit('addData', newUserData)
              ElMessage.success('用户添加成功')
              emit('update:visible', false)
            } else {
              ElMessage.error(res?.msg || '添加失败')
            }
          } else {
            // 编辑用户逻辑
            console.log('更新submitData:', submitData)
            // 不使用delete操作符，而是通过对象解构创建不包含password的新对象
            // eslint-disable-next-line @typescript-eslint/no-unused-vars
            const { password, ...updateData } = submitData
            const res = await updateUserApi((props.userData as any)?.id, updateData)

            if (res?.success === 1) {
              // 更新成功，发射updateData事件，传递更新后的数据
              const updatedData = {
                ...submitData,
                id: props.userData?.id,
                updateTime: new Date().toISOString()
              }
              emit('updateData', updatedData)
              ElMessage.success('用户更新成功')
              emit('update:visible', false)
            } else {
              ElMessage.error(res?.msg || '更新失败')
            }
          }
        } catch (error) {
          console.log('表单验证失败:', error)
        }
      }
    })
  }
</script>
