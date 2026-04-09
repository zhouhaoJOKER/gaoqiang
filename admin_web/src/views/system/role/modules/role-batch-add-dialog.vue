<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量添加角色"
    width="auto"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-add-container">
      <div class="table-container">
        <table class="batch-add-table">
          <thead>
            <tr>
              <th>角色名称</th>
              <th>角色编码</th>
              <th>数据权限</th>
              <th>是否启用</th>
              <th>角色描述</th>
              <th width="120">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in formData" :key="index">
              <td>
                <ElInput v-model="row.name" placeholder="请输入角色名称" size="small" />
              </td>
              <td>
                <ElInput v-model="row.code" placeholder="请输入角色编码" size="small" />
              </td>
              <td>
                <ElSelect
                  v-model="row.sign"
                  placeholder="请选择数据权限"
                  size="small"
                  style="width: 100%"
                >
                  <ElOption
                    v-for="option in levelOptions"
                    :key="option.value"
                    :label="option.label"
                    :value="option.value"
                  />
                </ElSelect>
              </td>
              <td>
                <ElSwitch v-model="row.is_open" size="small" />
              </td>
              <td>
                <ElInput
                  v-model="row.describe"
                  type="textarea"
                  :rows="1"
                  placeholder="请输入角色描述"
                  size="small"
                />
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
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">确定</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'RoleBatchAddDialog' })

  import { ref, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { batchActionRoleApi } from '@/api/role'

  interface RoleFormData {
    name: string
    code: string
    sign: string
    is_open: boolean
    describe: string
  }

  const props = defineProps<{
    modelValue: boolean
  }>()

  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    addData: [data: any[]]
    success: []
  }>()

  const dialogVisible = ref(false)
  const formData = ref<RoleFormData[]>([])
  const levelOptions = [
    { label: '个人', value: 'user' },
    { label: '部门', value: 'department' },
    { label: '公司', value: 'company' },
    { label: '全部', value: 'admin', disabled: true }
  ]

  const initFormData = (): RoleFormData[] => {
    return [
      {
        name: '',
        code: '',
        sign: '1',
        is_open: true,
        describe: ''
      },
      {
        name: '',
        code: '',
        sign: '1',
        is_open: true,
        describe: ''
      }
    ]
  }

  // 监听对话框显示状态
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        formData.value = initFormData()
      }
    }
  )

  // 添加新行
  const addRow = (index: number | undefined) => {
    const newRow: RoleFormData = {
      name: '',
      code: '',
      sign: '1',
      is_open: true,
      describe: ''
    }

    if (typeof index === 'number') {
      formData.value.splice(index + 1, 0, newRow)
    } else {
      formData.value.push(newRow)
    }
  }

  // 复制行
  const copyRow = (index: number) => {
    const rowToCopy = { ...formData.value[index] }
    formData.value.splice(index + 1, 0, rowToCopy)
  }

  // 删除行
  const removeRow = (index: number) => {
    if (formData.value.length > 1) {
      formData.value.splice(index, 1)
    } else {
      ElMessage.warning('至少保留一行数据')
    }
  }

  // 处理关闭
  const handleClose = () => {
    emit('update:modelValue', false)
    formData.value = []
  }

  // 提交表单
  const handleSubmit = async () => {
    // 验证数据
    const invalidRows = formData.value.filter((row) => !row.name || !row.code || !row.sign)
    if (invalidRows.length > 0) {
      ElMessage.warning('请确保所有行都填写了角色名称、角色编码和数据权限')
      return
    }

    // 打印提交数据
    console.log('批量新增角色提交数据:', formData.value)

    batchActionRoleApi({
      actions: 'create',
      roles: formData.value
    })
      .then((res) => {
        if (res?.code === 200) {
          ElMessage.success(res?.msg || '批量新增成功')
          emit('update:modelValue', false)
          emit('success')
          emit('addData', res?.data)
          // 重置表单
          formData.value = initFormData()
        } else {
          ElMessage.error(res?.message || '批量新增失败')
        }
      })
      .catch((error) => {
        console.error('批量新增失败:', error)
        ElMessage.error('批量新增失败')
      })
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
  :deep(.el-textarea) {
    width: 100%;
  }

  :deep(.el-input__wrapper),
  :deep(.el-input-number),
  :deep(.el-textarea__wrapper) {
    border-radius: 2px;
    box-shadow: none;
    transition: all 0.2s;
  }

  :deep(.el-input__wrapper:hover),
  :deep(.el-input-number:hover),
  :deep(.el-textarea__wrapper:hover) {
    box-shadow: 0 0 0 2px rgb(64 158 255 / 20%);
  }

  :deep(.el-input__wrapper.is-focus),
  :deep(.el-input-number.is-focus),
  :deep(.el-textarea__wrapper.is-focus) {
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

  :deep(.el-button--primary) {
    background-color: #409eff;
    border-color: #409eff;
  }

  :deep(.el-button--success) {
    background-color: #67c23a;
    border-color: #67c23a;
  }

  :deep(.el-button--danger) {
    background-color: #f56c6c;
    border-color: #f56c6c;
  }

  /* 表格列宽调整 */
  .batch-add-table th:nth-child(1),
  .batch-add-table td:nth-child(1) {
    width: 180px;
  }

  .batch-add-table th:nth-child(2),
  .batch-add-table td:nth-child(2) {
    width: 150px;
  }

  /* 上级部门列 */
  .batch-add-table th:nth-child(3),
  .batch-add-table td:nth-child(3) {
    width: 200px;
    min-width: 200px;
  }

  /* 负责人列宽度调整 */
  .batch-add-table th:nth-child(4),
  .batch-add-table td:nth-child(4) {
    width: 250px;
    min-width: 250px;
  }

  /* 排序列宽度调整 */
  .batch-add-table th:nth-child(5),
  .batch-add-table td:nth-child(5) {
    width: 100px;
  }

  /* 状态列宽度调整，确保两个单选按钮能并排显示 */
  .batch-add-table th:nth-child(6),
  .batch-add-table td:nth-child(6) {
    width: 120px;
    min-width: 120px;
    white-space: nowrap;
  }

  .batch-add-table th:nth-child(7),
  .batch-add-table td:nth-child(7) {
    flex: 1;
    min-width: 200px;
  }

  .batch-add-table th:nth-child(8),
  .batch-add-table td:nth-child(8) {
    width: 120px;
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
