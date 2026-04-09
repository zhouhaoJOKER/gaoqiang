<template>
  <ElDialog
    v-model="visible"
    :title="dialogType === 'add' ? '新增角色' : '编辑角色'"
    width="30%"
    align-center
    @close="handleClose"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElFormItem label="角色名称" prop="name">
        <ElInput v-model="form.name" placeholder="请输入角色名称" />
      </ElFormItem>
      <ElFormItem label="角色编码" prop="code">
        <ElInput v-model="form.code" placeholder="请输入角色编码" />
      </ElFormItem>
      <ElFormItem label="数据权限" prop="sign">
        <ElSelect v-model="form.sign" placeholder="请输入数据权限">
          <ElOption
            v-for="role in levelOptions"
            :key="role?.value || 0"
            :value="role?.value || 0"
            :label="role?.label || ''"
            :disabled="role?.disabled || false"
          />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="描述" prop="describe">
        <ElInput v-model="form.describe" type="textarea" :rows="3" placeholder="请输入角色描述" />
      </ElFormItem>
      <ElFormItem label="启用">
        <ElSwitch v-model="form.is_open" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="handleClose">取消</ElButton>
      <ElButton type="primary" @click="handleSubmit">提交</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { createRoleApi, updateRoleApi } from '@/api/role'

  interface Props {
    modelValue: boolean
    dialogType: 'add' | 'edit'
    roleData?: any
  }

  interface OptionItem {
    label: string
    value: string
    disabled?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
    (e: 'updateData', data: any): void
    (e: 'addData', data: any): void
  }

  const levelOptions = ref<OptionItem[]>([])

  /**
   * 用户等级选项
   */
  levelOptions.value = [
    { label: '个人', value: 'user' },
    { label: '部门', value: 'department' },
    { label: '公司', value: 'company' },
    { label: '全部', value: 'admin', disabled: true }
  ]

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    dialogType: 'add',
    roleData: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [
      { required: true, message: '请输入角色名称', trigger: 'blur' },
      { min: 2, max: 20, message: '长度在 2 到 20 个字符', trigger: 'blur' }
    ],
    code: [
      { required: true, message: '请输入角色编码', trigger: 'blur' },
      { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
    ],
    sign: [{ required: true, message: '请输入数据权限', trigger: 'blur' }],
    describe: [{ required: false, message: '请输入角色描述', trigger: 'blur' }]
  })

  const form = reactive<any>({
    id: 0,
    name: '',
    code: '',
    sign: '',
    describe: '',
    created_time: '',
    updated_time: '',
    user_id: 0,
    updater_id: 0,
    is_open: true
  })

  // 监听弹窗打开，初始化表单数据
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        initForm()
      }
    },
    { immediate: true }
  )

  // 监听角色数据变化
  watch(
    () => props.roleData,
    (newData) => {
      if (newData && props.modelValue) {
        initForm()
      }
    },
    { deep: true }
  )

  const initForm = () => {
    if (props.dialogType === 'edit' && props.roleData) {
      Object.assign(form, {
        id: props.roleData.id,
        name: props.roleData.name,
        sign: props.roleData.sign,
        code: props.roleData.code,
        describe: props.roleData.describe,
        created_time: props.roleData.created_time,
        is_open: props.roleData.is_open
      })
    } else {
      Object.assign(form, {
        id: 0,
        name: '',
        code: '',
        sign: '',
        describe: '',
        created_time: '',
        updated_time: '',
        is_open: true
      })
    }
  }

  const handleClose = () => {
    visible.value = false
    formRef.value?.resetFields()
  }
  function createRole(form: any) {
    // 创建角色
    createRoleApi(form).then((res) => {
      if (res && res.code === 200) {
        ElMessage.success('新增成功')
        emit('success')
        emit('addData', res.data)
        handleClose()
      }
    })
  }
  function updateRole(form: any) {
    // 更新角色
    updateRoleApi(form.id, form).then((res) => {
      if (res && res.code === 200) {
        ElMessage.success('修改成功')
        emit('success')

        emit('updateData', res.data)
        handleClose()
      }
    })
  }

  const handleSubmit = async () => {
    if (!formRef.value) return

    try {
      await formRef.value.validate()

      // 准备提交的数据
      const submitData = {
        ...form,
        roleCode: form.roleCode?.roleCode || form.roleCode,
        status: form.status ? 1 : 0
      }

      // TODO: 调用新增/编辑接口
      if (props.dialogType === 'add') {
        await createRole(submitData)
      } else {
        await updateRole(submitData)
      }
      // const message = props.dialogType === 'add' ? '新增成功' : '修改成功'
      // ElMessage.success(message)
      // emit('success')
      // handleClose()
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }
</script>
