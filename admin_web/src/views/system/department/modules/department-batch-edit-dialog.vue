<!-- 部门批量修改弹窗组件 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量修改部门"
    width="800px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-edit-container">
      <!-- 字段选择区域 -->
      <div class="field-selection">
        <div class="flex justify-between items-center mb-0">
          <h3>选择要修改的字段</h3>
          <ElButton type="primary" size="small" @click="toggleSelectAll">
            {{ isAllSelected ? '取消全选' : '全选' }}
          </ElButton>
        </div>
        <ElCheckboxGroup v-model="selectedFields">
          <ElSpace wrap>
            <ElCheckbox v-for="field in fields" :key="field.prop" :label="field.prop">
              {{ field.label }}
            </ElCheckbox>
          </ElSpace>
        </ElCheckboxGroup>
      </div>

      <!-- 表单区域 -->
      <div class="form-container">
        <h3>修改内容</h3>
        <ElForm ref="formRef" :model="formData" label-width="120px">
          <!-- 部门名称 -->
          <ElFormItem v-if="selectedFields.includes('name')" label="部门名称">
            <ElInput v-model="formData.name" placeholder="请输入部门名称" />
          </ElFormItem>

          <!-- 部门编码 -->
          <ElFormItem v-if="selectedFields.includes('code')" label="部门编码">
            <ElInput v-model="formData.code" placeholder="请输入部门编码" />
          </ElFormItem>

          <!-- 上级部门 -->
          <ElFormItem v-if="selectedFields.includes('parent_id')" label="上级部门">
            <ElTreeSelect
              v-model="formData.parent_id"
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

          <!-- 负责人 -->
          <ElFormItem v-if="selectedFields.includes('manager_id')" label="负责人">
            <div class="flex gap-2">
              <ElInput
                v-model="formData.manager_name"
                placeholder="请选择负责人"
                style="flex: 1; cursor: pointer"
                @click="showUserSelectDialog"
                @keyup.enter="showUserSelectDialog"
              />
              <ElButton @click="clearManager" v-if="formData.manager_id"> 清除 </ElButton>
            </div>
          </ElFormItem>

          <!-- 排序 -->
          <ElFormItem v-if="selectedFields.includes('sort')" label="排序">
            <ElInput-number v-model="formData.sort" :min="0" :step="1" />
          </ElFormItem>

          <!-- 状态 -->
          <ElFormItem v-if="selectedFields.includes('status')" label="状态">
            <ElRadioGroup v-model="formData.status">
              <ElRadio label="1">启用</ElRadio>
              <ElRadio label="0">禁用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>

          <!-- 备注 -->
          <ElFormItem v-if="selectedFields.includes('remark')" label="备注">
            <ElInput v-model="formData.remark" type="textarea" placeholder="请输入备注" :rows="3" />
          </ElFormItem>
        </ElForm>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交修改</ElButton>
      </span>
    </template>
  </ElDialog>

  <!-- 用户选择弹窗 -->
  <UserSelectDialog v-model="userSelectDialogVisible" @select="handleUserSelect" />
</template>

<script setup lang="ts">
  defineOptions({ name: 'DepartmentBatchEditDialog' })

  import { ref, defineProps, defineEmits, watch, onMounted, computed } from 'vue'
  import { ElMessage } from 'element-plus'
  import { listDepartmentTreeApi, batchActionDepartmentApi } from '@/api/department'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
    selectedIds?: number[]
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const formRef = ref()
  const departmentTreeData = ref<any[]>([])
  const treeSelectProps = {
    value: 'id',
    label: 'name',
    children: 'children'
  }

  // 用户选择弹窗相关
  const userSelectDialogVisible = ref(false)

  const formData = ref({
    name: '',
    code: '',
    parent_id: '',
    manager_id: '',
    manager_name: '',
    sort: 0,
    status: '1',
    remark: ''
  })

  // 显示用户选择弹窗
  const showUserSelectDialog = () => {
    userSelectDialogVisible.value = true
  }

  // 处理用户选择
  const handleUserSelect = (user: any) => {
    formData.value.manager_id = user.id
    formData.value.manager_name = user.name
  }

  // 清除负责人
  const clearManager = () => {
    formData.value.manager_id = ''
    formData.value.manager_name = ''
  }

  // 字段定义
  const fields = [
    { prop: 'name', label: '部门名称' },
    { prop: 'code', label: '部门编码' },
    { prop: 'parent_id', label: '上级部门' },
    { prop: 'manager_id', label: '负责人' },
    { prop: 'sort', label: '排序' },
    { prop: 'status', label: '状态' },
    { prop: 'remark', label: '备注' }
  ]

  // 默认选中所有字段
  const selectedFields = ref(fields.map((field) => field.prop))

  // 判断是否全选
  const isAllSelected = computed(() => {
    return selectedFields.value.length === fields.length
  })

  // 全选/取消全选
  const toggleSelectAll = () => {
    if (isAllSelected.value) {
      // 取消全选
      selectedFields.value = []
    } else {
      // 全选
      selectedFields.value = fields.map((field) => field.prop)
    }
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

  // 取消操作
  const handleCancel = () => {
    dialogVisible.value = false
  }

  // 提交修改
  const handleSubmit = async () => {
    // 验证表单
    if (!selectedFields.value.length) {
      ElMessage.warning('请至少选择一个要修改的字段')
      return
    }

    try {
      // 构建修改数据
      const updateData = {
        actions: 'update',
        fields: selectedFields.value,
        values: formData.value,
        ids: props.selectedIds || []
      }

      // 调用批量修改API
      const res = await batchActionDepartmentApi(updateData)
      console.log('批量修改提交数据:', updateData)
      console.log('批量修改API响应:', res)

      ElMessage.success('批量修改成功')
      dialogVisible.value = false
      emit('success')
    } catch (error) {
      console.error('批量修改失败:', error)
      ElMessage.error('批量修改失败，请重试')
    }
  }
</script>

<style scoped>
  .batch-edit-container {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .field-selection,
  .form-container {
    padding: 16px;
    background-color: #fafafa;
    border: 1px solid #ebeef5;
    border-radius: 4px;
  }

  h3 {
    margin: 0 0 16px;
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .field-selection {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .form-container {
    background-color: #fff;
  }
</style>
