<template>
  <ElDialog
    v-model="visible"
    :title="multiple ? '选择多个用户' : '选择用户'"
    width="800px"
    @close="handleClose"
  >
    <div class="mb-4">
      <ElInput
        v-model="searchQuery"
        placeholder="请输入用户名或邮箱搜索"
        clearable
        @input="handleSearch"
        @clear="handleSearch"
      >
        <template #append>
          <ElButton type="primary" @click="handleSearch">搜索</ElButton>
        </template>
      </ElInput>
    </div>

    <ElTable
      ref="tableRef"
      :data="userList"
      border
      stripe
      highlight-current-row
      @row-click="handleRowClick"
      @selection-change="handleSelectionChange"
    >
      <ElTableColumn v-if="multiple" type="selection" width="55" />
      <ElTableColumn prop="id" label="ID" width="80" />
      <ElTableColumn prop="name" label="用户名" min-width="120" />
      <ElTableColumn prop="email" label="邮箱" min-width="150" />
    </ElTable>

    <div class="mt-4 flex justify-between items-center">
      <div>
        <ElButton
          type="primary"
          @click="handleConfirm"
          :disabled="multiple ? selectedUsers.length === 0 : false"
        >
          {{ multiple ? '确认选择' : '选择' }}
        </ElButton>
        <ElButton @click="handleClose">取消</ElButton>
      </div>
      <ElPagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { TableInstance } from 'element-plus'
  import { listUserApi } from '@/api/user'

  interface Props {
    modelValue: boolean
    multiple?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'select', user: any): void
    (e: 'select-multiple', users: any[]): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    multiple: false
  })

  const emit = defineEmits<Emits>()

  const visible = ref(false)
  const tableRef = ref<TableInstance>()
  const searchQuery = ref('')
  const currentPage = ref(1)
  const pageSize = ref(10)
  const total = ref(0)
  const userList = ref<any[]>([])
  const selectedUser = ref<any>(null)
  const selectedUsers = ref<any[]>([])

  // 监听弹窗显示状态
  watch(
    () => props.modelValue,
    (newVal) => {
      visible.value = newVal
      if (newVal) {
        initData()
      }
    },
    { immediate: true }
  )

  // 监听弹窗内部状态变化
  watch(visible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 初始化数据
  const initData = async () => {
    searchQuery.value = ''
    currentPage.value = 1
    selectedUser.value = null
    selectedUsers.value = []
    await fetchUserList()
  }
  // 获取用户列表
  const fetchUserList = async () => {
    try {
      const res = await listUserApi({
        current: currentPage.value,
        size: pageSize.value,
        'q[name_cont]': searchQuery.value,
        'q[email_cont]': searchQuery.value
      })
      if (res && res.code === 200) {
        userList.value = res.data || []
        total.value = res.total || 0
      }
    } catch (error) {
      console.error('获取用户列表失败:', error)
      ElMessage.error('获取用户列表失败')
    }
  }

  // 搜索用户
  const handleSearch = async () => {
    currentPage.value = 1
    await fetchUserList()
  }

  // 分页大小变化
  const handleSizeChange = async (val: number) => {
    pageSize.value = val
    await fetchUserList()
  }

  // 当前页变化
  const handleCurrentChange = async (val: number) => {
    currentPage.value = val
    await fetchUserList()
  }

  // 行点击
  const handleRowClick = (row: any) => {
    if (props.multiple) {
      // 多选模式下，切换行选择状态
      tableRef.value?.toggleRowSelection(row)
    } else {
      // 单选模式下，直接选择并关闭弹窗
      selectedUser.value = row
      emit('select', selectedUser.value)
      handleClose()
    }
  }

  // 选择变化
  const handleSelectionChange = (selection: any[]) => {
    if (props.multiple) {
      selectedUsers.value = selection
    }
  }

  // 确认选择
  const handleConfirm = () => {
    if (props.multiple) {
      if (selectedUsers.value.length === 0) {
        ElMessage.warning('请至少选择一个用户')
        return
      }
      emit('select-multiple', selectedUsers.value)
    } else {
      if (!selectedUser.value) {
        ElMessage.warning('请选择一个用户')
        return
      }
      emit('select', selectedUser.value)
    }
    handleClose()
  }

  // 关闭弹窗
  const handleClose = () => {
    visible.value = false
    selectedUser.value = null
    selectedUsers.value = []
    if (tableRef.value) {
      tableRef.value.clearSelection()
    }
  }

  // 初始加载
  onMounted(() => {
    if (visible.value) {
      fetchUserList()
    }
  })
</script>

<style scoped>
  .el-dialog__body {
    padding: 20px;
  }
</style>
