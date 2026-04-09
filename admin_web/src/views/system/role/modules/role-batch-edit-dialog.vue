<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量编辑角色"
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
          <!-- 角色名称 -->
          <ElFormItem v-if="selectedFields.includes('name')" label="角色名称">
            <ElInput v-model="formData.name" placeholder="请输入角色名称" />
          </ElFormItem>

          <!-- 角色编码 -->
          <ElFormItem v-if="selectedFields.includes('code')" label="角色编码">
            <ElInput v-model="formData.code" placeholder="请输入角色编码" />
          </ElFormItem>

          <!-- 数据权限 -->
          <ElFormItem v-if="selectedFields.includes('sign')" label="数据权限">
            <ElSelect v-model="formData.sign" placeholder="请选择数据权限">
              <ElOption
                v-for="option in signOptions"
                :key="option.value"
                :label="option.label"
                :value="option.value"
              />
            </ElSelect>
          </ElFormItem>

          <!-- 是否启用 -->
          <ElFormItem v-if="selectedFields.includes('is_open')" label="是否启用">
            <ElRadioGroup v-model="formData.is_open">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">禁用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>

          <!-- 角色描述 -->
          <ElFormItem v-if="selectedFields.includes('describe')" label="角色描述">
            <ElInput
              v-model="formData.describe"
              type="textarea"
              :rows="3"
              placeholder="请输入角色描述"
            />
          </ElFormItem>
        </ElForm>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交修改</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'RoleBatchEditDialog' })

  import { ref, defineProps, defineEmits, watch, computed } from 'vue'
  import { ElMessage } from 'element-plus'
  import { batchActionRoleApi } from '@/api/role'

  // 定义 props
  const props = defineProps<{
    modelValue: boolean
    selectedRows?: any[]
  }>()

  // 定义事件
  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  // 响应式变量
  const dialogVisible = ref(props.modelValue)
  const formRef = ref()

  const formData = ref({
    name: '',
    code: '',
    sign: '',
    is_open: true,
    describe: ''
  })

  // 数据权限选项
  const signOptions = [
    { value: 'user', label: '个人数据' },
    { value: 'department', label: '部门数据' },
    { value: 'company', label: '公司数据' },
    { value: 'admin', label: '全部数据' }
  ]

  // 字段定义
  const fields = [
    { prop: 'name', label: '角色名称' },
    { prop: 'code', label: '角色编码' },
    { prop: 'sign', label: '数据权限' },
    { prop: 'is_open', label: '是否启用' },
    { prop: 'describe', label: '角色描述' }
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

  // 监听 modelValue 变化，更新 dialogVisible
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
    }
  )

  // 处理关闭
  const handleClose = () => {
    dialogVisible.value = false
  }

  // 提交表单
  const handleSubmit = async () => {
    // 验证表单
    if (!selectedFields.value.length) {
      ElMessage.warning('请至少选择一个要修改的字段')
      return
    }

    try {
      // 提取选中的ID
      const selectedIds = props.selectedRows?.map((row) => row.id) || []
      if (selectedIds.length === 0) {
        ElMessage.warning('请先选择要编辑的角色')
        return
      }

      // 构建修改数据
      const updateData = {
        actions: 'update',
        fields: selectedFields.value,
        values: formData.value,
        ids: selectedIds
      }

      // 调用批量修改API
      const res = await batchActionRoleApi(updateData)
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
