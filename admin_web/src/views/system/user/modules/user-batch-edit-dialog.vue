<!-- 用户批量编辑弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量编辑用户"
    width="1296px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-edit-container">
      <div class="table-container">
        <table class="batch-edit-table">
          <thead>
            <tr>
              <th>用户名</th>
              <th>邮箱</th>
              <th>手机号</th>
              <th>性别</th>
              <th>部门</th>
              <th>角色</th>
              <th>状态</th>
              <th width="120">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in formData" :key="index">
              <td>
                <ElInput v-model="row.name" placeholder="请输入用户名" size="small" />
              </td>
              <td>
                <ElInput v-model="row.email" placeholder="请输入邮箱" size="small" />
              </td>
              <td>
                <ElInput v-model="row.phone" placeholder="请输入手机号" size="small" />
              </td>
              <td>
                <ElSelect
                  v-model="row.sex"
                  placeholder="请选择性别"
                  size="small"
                  style="width: 100%"
                >
                  <ElOption label="男" value="男" />
                  <ElOption label="女" value="女" />
                </ElSelect>
              </td>
              <td>
                <ElSelect
                  v-model="row.department_id"
                  placeholder="请选择部门"
                  size="small"
                  filterable
                  style="width: 100%"
                >
                  <ElOption
                    v-for="item in deptList"
                    :key="item?.id || 0"
                    :label="item?.name || ''"
                    :value="item?.id || 0"
                  />
                </ElSelect>
              </td>
              <td>
                <ElSelect
                  v-model="row.role_id"
                  placeholder="请选择角色"
                  size="small"
                  style="width: 100%"
                >
                  <ElOption
                    v-for="role in roleList"
                    :key="role?.id || 0"
                    :label="role?.name || ''"
                    :value="role?.id || 0"
                  />
                </ElSelect>
              </td>
              <td>
                <ElRadioGroup v-model="row.status" size="small" class="status-radio-group">
                  <ElRadio label="1">启用</ElRadio>
                  <ElRadio label="0">禁用</ElRadio>
                </ElRadioGroup>
              </td>
              <td class="operation-buttons">
                <ElSpace>
                  <ElButton
                    type="primary"
                    size="small"
                    @click="addRow(index)"
                    circle
                    title="新增行"
                  >
                    <ArtSvgIcon icon="ri:add-line" />
                  </ElButton>
                  <ElButton
                    type="success"
                    size="small"
                    @click="copyRow(index)"
                    circle
                    title="复制行"
                  >
                    <ArtSvgIcon icon="ri:file-copy-2-line" />
                  </ElButton>
                  <ElButton
                    type="danger"
                    size="small"
                    @click="removeRow(index)"
                    circle
                    :disabled="formData.length <= 1"
                    title="删除行"
                  >
                    <ArtSvgIcon icon="ri:delete-row" />
                  </ElButton>
                </ElSpace>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交编辑</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'UserBatchEditDialog' })

  import { ref, defineProps, defineEmits, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { updateUserApi } from '@/api/user'
  import { listPropertyApi } from '@/api/property'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
    selectedData?: any[]
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    updateData: [data: any[]]
    success: []
  }>()

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const roleList = ref<any[]>([])
  const deptList = ref<any[]>([])

  // 初始化表单数据
  const initFormData = () => {
    const baseData = [
      {
        id: '', // 编辑时需要保留id
        name: '',
        email: '',
        phone: '',
        sex: '男',
        department_id: '',
        role_id: '',
        status: '1'
      }
    ]

    // 如果有选中数据，则使用选中数据
    if (props.selectedData && props.selectedData.length > 0) {
      return props.selectedData.map((item) => ({
        id: item.id,
        name: item.name || '',
        email: item.email || '',
        phone: item.phone || '',
        sex: item.sex || '男',
        department_id: item.department_id || '',
        role_id: item.role_id || '',
        status: String(item.status || '1')
      }))
    }

    return baseData
  }

  const formData = ref(initFormData())

  // 获取部门和角色数据
  const getPropertyData = async () => {
    try {
      const res = await listPropertyApi({
        tag: 'users'
      })
      if (res && res.roles) {
        roleList.value = res.roles
      }
      if (res && res.departments) {
        deptList.value = res.departments
      }
    } catch (error) {
      console.error('获取属性列表失败:', error)
      ElMessage.error('获取属性列表失败')
    }
  }

  // 监听 dialogVisible 变化，向父组件传递
  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        initFormData()
        getPropertyData()
      }
    }
  )

  // 监听选中数据变化，更新表单数据
  watch(
    () => props.selectedData,
    (newData) => {
      if (newData && newData.length > 0) {
        formData.value = newData.map((item) => ({
          id: item.id,
          name: item.name || '',
          email: item.email || '',
          phone: item.phone || '',
          sex: item.sex || '男',
          department_id: item.department_id || '',
          role_id: item.role_id || '',
          status: String(item.status || '1')
        }))
      }
    },
    { deep: true }
  )

  // 组件挂载时获取属性数据
  onMounted(() => {
    if (dialogVisible.value) {
      getPropertyData()
    }
  })

  // 添加新行
  const addRow = (index: number) => {
    formData.value.splice(index + 1, 0, {
      id: '', // 新行没有id
      name: '',
      email: '',
      phone: '',
      sex: '男',
      department_id: '',
      role_id: '',
      status: '1'
    })
  }

  // 复制行
  const copyRow = (index: number) => {
    const rowToCopy = { ...formData.value[index] }
    delete rowToCopy.id // 复制行不保留原始id
    formData.value.splice(index + 1, 0, rowToCopy)
  }

  // 删除行
  const removeRow = (index: number) => {
    if (formData.value.length <= 1) {
      ElMessage.warning('至少保留一行数据')
      return
    }
    formData.value.splice(index, 1)
  }

  // 取消操作
  const handleCancel = () => {
    dialogVisible.value = false
  }

  // 验证手机号格式
  const validatePhone = (phone: string) => {
    if (!phone) return true
    return /^1[3-9]\d{9}$/.test(phone)
  }

  // 提交编辑
  const handleSubmit = async () => {
    // 验证数据
    const invalidRows = formData.value.filter((row) => !row.name || !row.role_id)
    if (invalidRows.length > 0) {
      ElMessage.warning('请确保所有行都填写了用户名和选择了角色')
      return
    }

    // 验证手机号格式
    const invalidPhoneRows = formData.value.filter((row) => row.phone && !validatePhone(row.phone))
    if (invalidPhoneRows.length > 0) {
      ElMessage.warning('请确保所有手机号格式正确')
      return
    }

    // 打印输入的值
    console.log('批量编辑提交数据:', formData.value)

    try {
      const updatedUsers: any[] = []

      // 逐个更新用户
      for (const userData of formData.value) {
        const submitData = {
          ...userData,
          status: userData.status === '1' ? 1 : 0
        }

        // 有id时更新，无id时创建（这里可以根据实际需求调整）
        const res = await updateUserApi(String(userData.id), submitData)
        if (res?.success === 1) {
          const updatedUserData = {
            ...submitData,
            id: res.id || userData.id || Date.now(),
            updateTime: new Date().toISOString()
          }
          updatedUsers.push(updatedUserData)
        } else {
          throw new Error(res?.msg || '更新用户失败')
        }
      }

      ElMessage.success('批量编辑成功')
      dialogVisible.value = false
      emit('success')
      emit('updateData', updatedUsers)
      // 重置表单
      resetForm()
    } catch (error: any) {
      console.error('批量编辑失败:', error)
      ElMessage.error(error.message || '批量编辑失败')
    }
  }

  // 重置表单
  const resetForm = () => {
    formData.value = initFormData()
  }
</script>

<style scoped>
  .batch-edit-container {
    max-height: 500px;
    overflow-y: auto;
  }

  .table-container {
    overflow: hidden;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
  }

  .batch-edit-table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    background-color: #fff;
  }

  .batch-edit-table th,
  .batch-edit-table td {
    padding: 12px 8px;
    text-align: left;
    vertical-align: middle;
    border: 1px solid #dcdfe6;
  }

  .batch-edit-table th {
    font-size: 14px;
    font-weight: 700;
    font-weight: bold;
    color: #303133;
    white-space: nowrap;
    background-color: #f5f7fa;
  }

  .batch-edit-table td {
    background-color: #fff;
    transition: background-color 0.2s;
  }

  .batch-edit-table tr:hover td {
    background-color: #fafafa;
  }

  /* 状态单选按钮组样式 */
  :deep(.status-radio-group) {
    display: flex;
    flex-wrap: nowrap;
    gap: 16px;
    align-items: center;
    width: 100%;
    white-space: nowrap;
  }

  :deep(.status-radio-group .el-radio) {
    margin: 0;
    white-space: nowrap;
  }

  /* 输入控件样式调整 */
  :deep(.el-input),
  :deep(.el-input-number),
  :deep(.el-radio-group),
  :deep(.el-select),
  :deep(.el-textarea) {
    width: 100%;
  }

  :deep(.el-input__wrapper),
  :deep(.el-input-number),
  :deep(.el-textarea__wrapper),
  :deep(.el-select__wrapper) {
    border-radius: 2px;
    box-shadow: none;
    transition: all 0.2s;
  }

  :deep(.el-input__wrapper:hover),
  :deep(.el-input-number:hover),
  :deep(.el-textarea__wrapper:hover),
  :deep(.el-select__wrapper:hover) {
    box-shadow: 0 0 0 2px rgb(64 158 255 / 20%);
  }

  :deep(.el-input__wrapper.is-focus),
  :deep(.el-input-number.is-focus),
  :deep(.el-textarea__wrapper.is-focus),
  :deep(.el-select__wrapper.is-focus) {
    border-color: #409eff;
    box-shadow: 0 0 0 2px rgb(64 158 255 / 20%);
  }

  /* 操作按钮样式 */
  .operation-buttons {
    display: flex;
    gap: 6px;
    justify-content: center;
    padding: 4px 0;
  }

  :deep(.el-button) {
    border-radius: 2px;
    transition: all 0.2s;
  }

  /* 表格列宽调整 */
  .batch-edit-table th:nth-child(1),
  .batch-edit-table td:nth-child(1) {
    width: 120px;
  }

  .batch-edit-table th:nth-child(2),
  .batch-edit-table td:nth-child(2) {
    width: 180px;
  }

  .batch-edit-table th:nth-child(3),
  .batch-edit-table td:nth-child(3) {
    width: 120px;
  }

  .batch-edit-table th:nth-child(4),
  .batch-edit-table td:nth-child(4) {
    width: 80px;
  }

  .batch-edit-table th:nth-child(5),
  .batch-edit-table td:nth-child(5) {
    width: 150px;
  }

  .batch-edit-table th:nth-child(6),
  .batch-edit-table td:nth-child(6) {
    width: 120px;
  }

  .batch-edit-table th:nth-child(7),
  .batch-edit-table td:nth-child(7) {
    width: 100px;
  }

  /* 自定义滚动条样式 */
  .batch-edit-container::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  .batch-edit-container::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  .batch-edit-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border: 2px solid #f1f1f1;
    border-radius: 4px;
  }

  .batch-edit-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }
</style>
