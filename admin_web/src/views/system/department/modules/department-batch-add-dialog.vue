<!-- 部门批量新增弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量新增部门"
    width="1296px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-add-container">
      <div class="table-container">
        <table class="batch-add-table">
          <thead>
            <tr>
              <th>上级部门</th>
              <th>部门名称</th>
              <th>部门编码</th>
              <th>负责人</th>
              <th>排序</th>
              <th>状态</th>
              <th>备注</th>
              <th width="120">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in formData" :key="index">
              <td>
                <ElTreeSelect
                  v-model="row.parent_id"
                  :data="departmentTreeData"
                  :props="treeSelectProps"
                  :expand-on-click-node="true"
                  :only-show-leaf-nodes="false"
                  placeholder="请选择上级部门"
                  check-strictly
                  filterable
                  clearable
                  size="small"
                  style="width: 100%"
                />
              </td>
              <td>
                <ElInput v-model="row.name" placeholder="请输入部门名称" size="small" />
              </td>
              <td>
                <ElInput v-model="row.code" placeholder="请输入部门编码" size="small" />
              </td>
              <td>
                <div class="flex gap-1">
                  <ElInput
                    v-model="row.manager_name"
                    placeholder="请选择负责人"
                    size="small"
                    style="flex: 1; cursor: pointer"
                    @click="showUserSelectDialog(index)"
                    @keyup.enter="showUserSelectDialog(index)"
                  />
                  <ElButton size="small" @click="clearManager(index)" v-if="row.manager_id">
                    清除
                  </ElButton>
                </div>
              </td>
              <td>
                <ElInput-number v-model="row.sort" :min="0" :step="1" size="small" />
              </td>
              <td>
                <ElRadioGroup v-model="row.status" size="small" class="status-radio-group">
                  <ElRadio label="1">启用</ElRadio>
                  <ElRadio label="0">禁用</ElRadio>
                </ElRadioGroup>
              </td>
              <td>
                <ElInput
                  v-model="row.remark"
                  type="textarea"
                  placeholder="请输入备注"
                  size="small"
                  :rows="1"
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
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交新增</ElButton>
      </span>
    </template>
  </ElDialog>

  <!-- 用户选择弹窗 -->
  <UserSelectDialog v-model="userSelectDialogVisible" @select="handleUserSelect" />
</template>

<script setup lang="ts">
  defineOptions({ name: 'DepartmentBatchAddDialog' })

  import { ref, defineProps, defineEmits, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { batchActionDepartmentApi, listDepartmentTreeApi } from '@/api/department'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'

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
  const departmentTreeData = ref<any[]>([])
  const treeSelectProps = {
    value: 'id',
    label: 'name',
    children: 'children'
  }
  // 用户选择弹窗相关
  const userSelectDialogVisible = ref(false)
  const currentEditRowIndex = ref(-1)

  const formData = ref([
    {
      name: '',
      code: '',
      parent_id: '',
      manager_id: '',
      manager_name: '',
      sort: 0,
      status: '1',
      remark: ''
    },
    {
      name: '',
      code: '',
      parent_id: '',
      manager_id: '',
      manager_name: '',
      sort: 0,
      status: '1',
      remark: ''
    },
    {
      name: '',
      code: '',
      parent_id: '',
      manager_id: '',
      manager_name: '',
      sort: 0,
      status: '1',
      remark: ''
    }
  ])

  // 显示用户选择弹窗
  const showUserSelectDialog = (index: number) => {
    currentEditRowIndex.value = index
    userSelectDialogVisible.value = true
  }

  // 处理用户选择
  const handleUserSelect = (user: any) => {
    if (currentEditRowIndex.value >= 0) {
      formData.value[currentEditRowIndex.value].manager_id = user.id
      formData.value[currentEditRowIndex.value].manager_name = user.name
    }
  }

  // 清除负责人
  const clearManager = (index: number) => {
    formData.value[index].manager_id = ''
    formData.value[index].manager_name = ''
  }

  // 监听 dialogVisible 变化，向父组件传递
  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 获取部门树数据
  const getDepartmentTree = async () => {
    try {
      const res = await listDepartmentTreeApi({})
      let treeData = []
      if (res?.data) {
        if (Array.isArray(res.data)) {
          treeData = res.data
        } else if (typeof res.data === 'object') {
          treeData = res.data.departments || res.data.items || res.data.list || []
          if (!Array.isArray(treeData) && (res.data.id || res.data.children)) {
            treeData = [res.data]
          }
        }
      }
      departmentTreeData.value = treeData
    } catch (error) {
      console.error('获取部门树数据失败:', error)
      ElMessage.error('获取部门树数据失败')
      departmentTreeData.value = []
    }
  }

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        getDepartmentTree()
      }
    }
  )

  // 组件挂载时获取部门树数据
  onMounted(() => {
    if (dialogVisible.value) {
      getDepartmentTree()
    }
  })

  // 添加新行
  const addRow = (index: number) => {
    formData.value.splice(index + 1, 0, {
      name: '',
      code: '',
      parent_id: '',
      manager_id: '',
      manager_name: '',
      sort: 0,
      status: '1',
      remark: ''
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

  // 提交新增
  const handleSubmit = () => {
    // 验证数据
    const invalidRows = formData.value.filter((row) => !row.name || !row.code)
    if (invalidRows.length > 0) {
      ElMessage.warning('请确保所有行都填写了部门名称和部门编码')
      return
    }
    // 打印输入的值
    console.log('批量新增提交数据:', formData.value)
    batchActionDepartmentApi({
      actions: 'create',
      departments: formData.value
    })
      .then((res) => {
        if (res?.code === 200) {
          ElMessage.success('批量新增成功')
          dialogVisible.value = false
          emit('success')
          emit('addData', res?.data)
          // 重置表单
          resetForm()
        } else {
          ElMessage.error(res?.message || '批量新增失败')
        }
      })
      .catch((error) => {
        console.error('批量新增失败:', error)
        ElMessage.error('批量新增失败')
      })
  }

  // 重置表单
  const resetForm = () => {
    formData.value = [
      {
        name: '',
        code: '',
        parent_id: '',
        manager_id: '',
        manager_name: '',
        sort: 0,
        status: '1',
        remark: ''
      },
      {
        name: '',
        code: '',
        parent_id: '',
        manager_id: '',
        manager_name: '',
        sort: 0,
        status: '1',
        remark: ''
      },
      {
        name: '',
        code: '',
        parent_id: '',
        manager_id: '',
        manager_name: '',
        sort: 0,
        status: '1',
        remark: ''
      }
    ]
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
