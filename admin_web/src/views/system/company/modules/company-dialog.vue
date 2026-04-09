<template>
  <ElDialog
    :title="dialogTitle"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="800px"
    align-center
    class="company-dialog"
    @closed="handleClosed"
  >
    <ArtForm
      ref="formRef"
      v-model="form"
      :items="formItems"
      :rules="rules"
      :span="width > 640 ? 24 : 24"
      :gutter="20"
      label-width="140px"
      :show-reset="false"
      :show-submit="false"
    >
      <!-- 上级公司树形选择器自定义插槽 -->
      <template #parent_id>
        <ElTreeSelect
          v-model="form.parent_id"
          :data="companyTreeData"
          :props="treeSelectProps"
          :expand-on-click-node="true"
          :only-show-leaf-nodes="false"
          placeholder="选择上级公司"
          check-strictly
          filterable
          clearable
          style="width: 100%"
        />
      </template>

      <!-- 负责人选择器自定义插槽 -->
      <template #user_id>
        <div class="flex gap-2">
          <ElInput
            v-model="form.user_name"
            placeholder="选择负责人"
            style="flex: 1; cursor: pointer"
            @click="showUserSelectDialog"
            @keyup.enter="showUserSelectDialog"
          />
          <ElButton v-if="form.user_id" @click="clearUser"> 清除 </ElButton>
        </div>
      </template>
    </ArtForm>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleCancel">取 消</ElButton>
        <ElButton type="primary" @click="handleSubmit">确 定</ElButton>
      </span>
    </template>
  </ElDialog>

  <!-- 用户选择弹窗 -->
  <UserSelectDialog v-model="userSelectDialogVisible" @select="handleUserSelect" />
</template>

<script setup lang="ts">
  import type { FormRules } from 'element-plus'
  import { ElButton, ElMessage, ElTreeSelect } from 'element-plus'
  import type { FormItem } from '@/components/core/forms/art-form/index.vue'
  import ArtForm from '@/components/core/forms/art-form/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import { computed, reactive, ref, watch, nextTick, onMounted } from 'vue'
  import { useWindowSize } from '@vueuse/core'

  import { listCompanyApi } from '@/api/company'

  const { width } = useWindowSize()

  // 公司树形数据
  const companyTreeData = ref<any[]>([])
  const loadingCompanies = ref(false)

  // 树选择器配置
  const treeSelectProps = {
    label: 'name',
    children: 'children',
    value: 'id'
  }

  // 用户选择弹窗可见性
  const userSelectDialogVisible = ref(false)
  const loadCompanyTreeData = async () => {
    loadingCompanies.value = true
    try {
      const response = await listCompanyApi({})
      const companies = (response as any).data || []
      companyTreeData.value = buildTree(companies)
    } catch (error) {
      console.error('获取公司列表失败:', error)
    } finally {
      loadingCompanies.value = false
    }
  }

  /**
   * 构建树形结构
   */
  const buildTree = (items: any[]): any[] => {
    const map: any = {}
    const tree: any[] = []

    // 构建ID映射
    items.forEach((item) => {
      map[item.id] = { ...item, children: [] }
    })

    // 构建树形结构
    items.forEach((item) => {
      if (item.parent_id) {
        if (map[item.parent_id]) {
          map[item.parent_id].children.push(map[item.id])
        }
      } else {
        tree.push(map[item.id])
      }
    })

    // 为每个节点添加 isLeaf 属性
    const addIsLeafProperty = (nodes: any[]) => {
      nodes.forEach((node) => {
        node.isLeaf = node.children.length === 0
        if (node.children.length > 0) {
          addIsLeafProperty(node.children)
        }
      })
    }

    addIsLeafProperty(tree)

    return tree
  }

  /**
   * 组件挂载时加载公司数据
   */
  onMounted(() => {
    loadCompanyTreeData()
  })

  interface CompanyFormData {
    id: string
    parent_id: string
    name: string
    abbr: string
    credit_code: string
    user_id: string
    user_name: string
    logo: string
  }

  interface Props {
    visible: boolean
    editData?: any
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit', data: CompanyFormData): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false
  })

  const emit = defineEmits<Emits>()

  const formRef = ref()
  const isEdit = ref(false)

  const form = reactive<CompanyFormData>({
    id: '',
    parent_id: '',
    name: '',
    abbr: '',
    credit_code: '',
    user_id: '',
    user_name: '',
    logo: ''
  })

  const rules = reactive<FormRules>({
    name: [
      { required: true, message: '请输入公司名称', trigger: 'blur' },
      { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
    ]
  })

  /**
   * 监听公司名称变化，自动设置简称
   */
  watch(
    () => form.name,
    (newName) => {
      if (newName) {
        form.abbr = newName.substring(0, 4)
      }
    },
    { immediate: true }
  )

  /**
   * 表单项配置
   */
  const formItems = computed<FormItem[]>(() => {
    return [
      {
        label: '上级公司',
        key: 'parent_id',
        type: 'custom',
        span: 24
      },
      {
        label: '公司名称',
        key: 'name',
        type: 'input',
        props: { placeholder: '请输入公司名称' }
      },
      {
        label: '公司简称',
        key: 'abbr',
        type: 'input',
        props: { placeholder: '请输入公司简称' }
      },
      {
        label: '统一社会信用代码',
        key: 'credit_code',
        type: 'input',
        props: { placeholder: '请输入统一社会信用代码' }
      },
      {
        label: '负责人ID',
        key: 'user_id',
        type: 'custom',
        span: 24
      }
    ]
  })

  const dialogTitle = computed(() => {
    return isEdit.value ? '编辑公司' : '新建公司'
  })

  /**
   * 显示用户选择弹窗
   */
  const showUserSelectDialog = () => {
    userSelectDialogVisible.value = true
  }

  /**
   * 处理用户选择
   */
  const handleUserSelect = (user: any) => {
    form.user_id = user.id
    form.user_name = user.name
  }

  /**
   * 清除用户选择
   */
  const clearUser = () => {
    form.user_id = ''
    form.user_name = ''
  }

  /**
   * 重置表单数据
   */
  const resetForm = (): void => {
    formRef.value?.reset()
  }

  /**
   * 加载表单数据（编辑模式）
   */
  const loadFormData = (): void => {
    if (!props.editData) return

    isEdit.value = true

    const row = props.editData
    form.id = row.id || ''
    form.parent_id = row.parent_id || ''
    form.name = row.name || ''
    form.abbr = row.abbr || ''
    form.credit_code = row.credit_code || ''
    form.user_id = row.user_id || ''
    form.user_name = row.user_name || ''
    form.logo = row.logo || ''
  }

  /**
   * 提交表单
   */
  const handleSubmit = async (): Promise<void> => {
    if (!formRef.value) return

    try {
      await formRef.value.validate()

      const submitForm = { ...form }

      emit('submit', submitForm)
      handleCancel()
    } catch {
      ElMessage.error('表单校验失败，请检查输入')
    }
  }

  /**
   * 取消操作
   */
  const handleCancel = (): void => {
    emit('update:visible', false)
  }

  /**
   * 对话框关闭后的回调
   */
  const handleClosed = (): void => {
    resetForm()
    isEdit.value = false
  }

  /**
   * 监听对话框显示状态
   */
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        resetForm()
        nextTick(() => {
          if (props.editData) {
            loadFormData()
          }
        })
      }
    }
  )
</script>

<style scoped>
  .logo-input-wrapper {
    position: relative;
  }

  .logo-upload-btn {
    padding: 0;
    margin-left: 4px;
  }

  /* 输入控件样式调整 */
  :deep(.el-input),
  :deep(.el-input-number),
  :deep(.el-textarea) {
    width: 100%;
  }
</style>
