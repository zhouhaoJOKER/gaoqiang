<!-- 用户批量新增弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量新增用户"
    width="1296px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-add-container">
      <div class="table-container">
        <table class="batch-add-table">
          <thead>
            <tr>
              <th>用户名</th>
              <th>密码</th>
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
                <ElInput
                  v-model="row.password"
                  type="password"
                  placeholder="请输入密码"
                  size="small"
                />
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
        <ElButton type="primary" @click="handleSubmit">提交新增</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'UserBatchAddDialog' })

  import { ref, defineProps, defineEmits, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { createUserApi } from '@/api/user'
  import { listPropertyApi } from '@/api/property'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    addData: [data: any[]]
    success: []
  }>()

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const roleList = ref<any[]>([])
  const deptList = ref<any[]>([])

  // 随机生成字符串
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

  // 初始化表单数据
  const initFormData = () => {
    return [
      {
        name: '',
        password: randomStr(),
        email: randomEmail(),
        phone: '',
        sex: '男',
        department_id: '',
        role_id: '',
        status: '1'
      },
      {
        name: '',
        password: randomStr(),
        email: randomEmail(),
        phone: '',
        sex: '男',
        department_id: '',
        role_id: '',
        status: '1'
      },
      {
        name: '',
        password: randomStr(),
        email: randomEmail(),
        phone: '',
        sex: '男',
        department_id: '',
        role_id: '',
        status: '1'
      }
    ]
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
        getPropertyData()
      }
    }
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
      name: '',
      password: randomStr(),
      email: randomEmail(),
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

  // 提交新增
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
    console.log('批量新增提交数据:', formData.value)

    try {
      const newUsers: any[] = []

      // 逐个创建用户
      for (const userData of formData.value) {
        const submitData = {
          ...userData,
          status: userData.status === '1' ? 1 : 0
        }

        const res = await createUserApi(submitData)
        if (res?.success === 1) {
          const newUserData = {
            ...submitData,
            id: res.id || Date.now(),
            createTime: new Date().toISOString(),
            updateTime: new Date().toISOString()
          }
          newUsers.push(newUserData)
        } else {
          throw new Error(res?.msg || '创建用户失败')
        }
      }

      ElMessage.success('批量新增成功')
      dialogVisible.value = false
      emit('success')
      emit('addData', newUsers)
      // 重置表单
      resetForm()
    } catch (error: any) {
      console.error('批量新增失败:', error)
      ElMessage.error(error.message || '批量新增失败')
    }
  }

  // 重置表单
  const resetForm = () => {
    formData.value = initFormData()
  }
</script>

<style scoped>
  .batch-add-container {
    max-height: 500px;
    overflow-y: auto;
  }

  .table-container {
    overflow: hidden;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
  }

  .batch-add-table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    background-color: #fff;
  }

  .batch-add-table th,
  .batch-add-table td {
    padding: 12px 8px;
    text-align: left;
    vertical-align: middle;
    border: 1px solid #dcdfe6;
  }

  .batch-add-table th {
    font-size: 14px;
    font-weight: 700;
    font-weight: bold;
    color: #303133;
    white-space: nowrap;
    background-color: #f5f7fa;
  }

  .batch-add-table td {
    background-color: #fff;
    transition: background-color 0.2s;
  }

  .batch-add-table tr:hover td {
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
  .batch-add-table th:nth-child(1),
  .batch-add-table td:nth-child(1) {
    width: 120px;
  }

  .batch-add-table th:nth-child(2),
  .batch-add-table td:nth-child(2) {
    width: 120px;
  }

  .batch-add-table th:nth-child(3),
  .batch-add-table td:nth-child(3) {
    width: 180px;
  }

  .batch-add-table th:nth-child(4),
  .batch-add-table td:nth-child(4) {
    width: 120px;
  }

  .batch-add-table th:nth-child(5),
  .batch-add-table td:nth-child(5) {
    width: 80px;
  }

  .batch-add-table th:nth-child(6),
  .batch-add-table td:nth-child(6) {
    width: 150px;
  }

  .batch-add-table th:nth-child(7),
  .batch-add-table td:nth-child(7) {
    width: 120px;
  }

  .batch-add-table th:nth-child(8),
  .batch-add-table td:nth-child(8) {
    width: 100px;
  }

  /* 自定义滚动条样式 */
  .batch-add-container::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  .batch-add-container::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  .batch-add-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border: 2px solid #f1f1f1;
    border-radius: 4px;
  }

  .batch-add-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }
</style>
