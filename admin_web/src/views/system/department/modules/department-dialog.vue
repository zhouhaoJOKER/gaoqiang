<template>
  <ElDialog
    v-model="visible"
    :title="$t(`common.${dialogType}`) + '部门'"
    width="600px"
    align-left
    @close="handleClose"
  >
    <ElCard>
      <ElForm
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="auto"
        :disabled="dialogType === 'view'"
      >
        <ElFormItem label="上级" prop="parent_id">
          <ElTreeSelect
            v-model="form.parent_id"
            :data="departmentTreeData"
            :props="treeSelectProps"
            :expand-on-click-node="true"
            :only-show-leaf-nodes="false"
            placeholder="请选择上级部门"
            check-strictly
            filterable
            clearable
            style="width: 100%"
          />
        </ElFormItem>
        <ElFormItem label="名称" prop="name">
          <ElInput v-model="form.name" placeholder="请输入名称" />
        </ElFormItem>
        <ElFormItem label="编码" prop="code">
          <ElInput v-model="form.code" placeholder="请输入编码" />
        </ElFormItem>
        <ElFormItem label="负责人" prop="manager_id">
          <div class="flex gap-2">
            <ElInput
              v-model="form.manager_name"
              placeholder="请选择负责人"
              :disabled="dialogType === 'view'"
              style="flex: 1; cursor: pointer"
              @click="showUserSelectDialog"
              @keyup.enter="showUserSelectDialog"
            />
            <ElButton
              v-if="form.manager_id"
              @click="clearManager"
              :disabled="dialogType === 'view'"
            >
              清除
            </ElButton>
          </div>
        </ElFormItem>
        <ElFormItem label="排序" prop="sort">
          <ElInput v-model="form.sort" type="number" placeholder="请输入排序" />
        </ElFormItem>
        <ElFormItem label="描述" prop="remark">
          <ElInput v-model="form.remark" type="textarea" :rows="3" placeholder="请输入部门描述" />
        </ElFormItem>
        <ElFormItem label="启用">
          <ElSwitch v-model="form.status" />
        </ElFormItem>
      </ElForm>
      <!-- <div>{{ form }}</div> -->
      <template #footer>
        <span class="dialog-footer flex justify-end">
          <ElButton @click="handleClose">取消</ElButton>
          <ElButton type="primary" :disabled="dialogType === 'view'" @click="handleSubmit"
            >提交</ElButton
          >
        </span>
      </template>
    </ElCard>
  </ElDialog>

  <!-- 用户选择弹窗 -->
  <UserSelectDialog v-model="userSelectDialogVisible" @select="handleUserSelect" />
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { createDepartmentApi, updateDepartmentApi, listDepartmentTreeApi } from '@/api/department'
  import { $t } from '@/locales'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'

  interface Props {
    modelValue: boolean
    dialogType: 'add' | 'edit' | 'clone' | 'view'
    departmentData?: any
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
    { label: '全部', value: 'all', disabled: true }
  ]

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    dialogType: 'add',
    departmentData: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  const formRef = ref<FormInstance>()

  // 部门树数据
  const departmentTreeData = ref<any[]>([])
  const departmentTreeLoading = ref(false)

  // 树选择器配置
  const treeSelectProps = {
    label: 'name',
    children: 'children',
    value: 'id'
  }

  // 递归处理树节点，确保所有节点都可选择
  const processTreeNodes = (nodes: any[]) => {
    return nodes.map((node) => {
      const processedNode = {
        ...node,
        disabled: false // 确保所有节点都可选择
      }
      if (node.children && node.children.length > 0) {
        processedNode.children = processTreeNodes(node.children)
      }
      return processedNode
    })
  }

  // 获取部门树数据
  const getDepartmentTreeData = async () => {
    departmentTreeLoading.value = true
    try {
      const res = await listDepartmentTreeApi({})
      if (res && res.code === 200) {
        // 处理API响应，支持多种可能的数据结构
        let treeData = []
        if (Array.isArray(res.data)) {
          treeData = res.data
        } else if (typeof res.data === 'object') {
          treeData = res.data.departments || res.data.items || res.data.list || []
          if (!Array.isArray(treeData) && (res.data.id || res.data.children)) {
            treeData = [res.data]
          }
        }
        // 处理树节点，确保所有节点都可选择
        if (Array.isArray(treeData)) {
          departmentTreeData.value = processTreeNodes(treeData)
        } else {
          departmentTreeData.value = treeData
        }
      }
    } catch (error) {
      console.error('获取部门树数据失败:', error)
      ElMessage.error('获取部门树数据失败')
    } finally {
      departmentTreeLoading.value = false
    }
  }

  // 初始加载部门树数据
  onMounted(() => {
    getDepartmentTreeData()
  })

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

  // 用户选择弹窗可见性
  const userSelectDialogVisible = ref(false)

  const form = reactive<any>({
    id: '',
    parent_id: '',
    name: '',
    code: '',
    sign: '',
    describe: '',
    created_time: '',
    updated_time: '',
    user_id: 0,
    updater_id: 0,
    manager_id: '',
    manager_name: ''
  })

  // 显示用户选择弹窗
  const showUserSelectDialog = () => {
    userSelectDialogVisible.value = true
  }

  // 处理用户选择
  const handleUserSelect = (user: any) => {
    form.manager_id = user.id
    form.manager_name = user.name
  }

  // 清除负责人
  const clearManager = () => {
    form.manager_id = ''
    form.manager_name = ''
  }

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
    () => props.departmentData,
    (newData) => {
      if (newData && props.modelValue) {
        initForm()
      }
    },
    { deep: true }
  )

  const initForm = () => {
    if (
      (props.dialogType === 'edit' ||
        props.dialogType === 'clone' ||
        props.dialogType === 'view' ||
        props.dialogType === 'add') &&
      props.departmentData
    ) {
      Object.assign(form, {
        id: props.departmentData.id || '',
        parent_id: props.departmentData.parent_id || '',
        name: props.departmentData.name || '',
        sign: props.departmentData.sign || '',
        code: props.departmentData.code || '',
        describe: props.departmentData.describe || '',
        created_time: props.departmentData.created_time || '',
        updated_time: props.departmentData.updated_time || '',
        remark: props.departmentData.remark || '',
        status: props.departmentData.status,
        sort: props.departmentData.sort || 0,
        description: props.departmentData.description || '',
        manager_id: props.departmentData.manager_id || '',
        manager_name: props.departmentData.manager_name || ''
      })
    } else {
      Object.assign(form, {
        id: 0,
        parent_id: 0,
        name: '',
        code: '',
        sign: '',
        describe: '',
        created_time: '',
        updated_time: '',
        remark: '',
        status: '1',
        sort: 0,
        description: '',
        manager_id: '',
        manager_name: ''
      })
    }
  }

  const handleClose = () => {
    visible.value = false
    formRef.value?.resetFields()
  }
  function createDepartment(form: any) {
    // 创建角色
    createDepartmentApi(form).then((res) => {
      if (res && res.code === 200) {
        ElMessage.success('新增成功')
        emit('success')
        emit('addData', res.data)
        handleClose()
      }
    })
  }
  function updateDepartment(form: any) {
    // 更新角色
    updateDepartmentApi(form.id, form).then((res) => {
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
        await createDepartment(submitData)
      } else if (props.dialogType === 'clone') {
        const cloneData = {
          ...submitData,
          id: 0
        }
        await createDepartment(cloneData)
      } else {
        await updateDepartment(submitData)
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
