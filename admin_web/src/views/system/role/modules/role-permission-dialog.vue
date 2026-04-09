<template>
  <ElDialog
    v-model="visible"
    title="菜单权限"
    width="60vh"
    align-center
    class="el-dialog-border"
    @close="handleClose"
  >
    <ElScrollbar height="70vh">
      <ElTree
        ref="treeRef"
        :data="processedMenuList"
        show-checkbox
        node-key="name"
        :default-expand-all="isExpandAll"
        :default-checked-keys="[1, 2, 3]"
        :props="defaultProps"
        @check="handleTreeCheck"
      >
        <template #default="{ data }">
          <div style="display: flex; align-items: center">
            <span v-if="data.isAuth">
              {{ data.label }}
            </span>
            <span v-else>{{ defaultProps.label(data) }}</span>
          </div>
        </template>
      </ElTree>
    </ElScrollbar>
    <template #footer>
      <!-- <ElButton @click="outputSelectedData" style="margin-left: 8px">获取选中数据</ElButton> -->

      <ElButton @click="toggleExpandAll">{{ isExpandAll ? '全部收起' : '全部展开' }}</ElButton>
      <ElButton @click="toggleSelectAll" style="margin-left: 8px">{{
        isSelectAll ? '取消全选' : '全部选择'
      }}</ElButton>
      <ElButton type="primary" @click="savePermission">保存</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { computed, nextTick, ref, watch } from 'vue'
  import { listMenuApi } from '@/api/menu'
  import { updateRoleApi } from '@/api/role'
  // import { useMenuStore } from '@/store/modules/menu'
  import { formatMenuTitle } from '@/utils/router'
  import { ElMessage } from 'element-plus'

  type RoleListItem = Api.SystemManage.RoleListItem

  interface Props {
    modelValue: boolean
    roleData?: RoleListItem
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    roleData: undefined
  })

  const emit = defineEmits<Emits>()

  // const { menuList } = storeToRefs(useMenuStore())
  const menuList = ref<MenuNode[]>([])
  const treeRef = ref()
  const isExpandAll = ref(true)
  const isSelectAll = ref(false)
  // 状态管理
  const loading = ref(false)

  /**
   * 获取菜单列表数据
   */
  const getMenuList = async (): Promise<void> => {
    loading.value = true

    try {
      // 调用listMenuApi接口获取菜单数据
      const response = await listMenuApi({})
      // 使用records字段获取数据
      menuList.value = (response as any).data || []
    } catch (error: any) {
      console.error('获取菜单列表失败:', error)
      ElMessage.error('获取菜单列表失败')
      menuList.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * 弹窗显示状态双向绑定
   */
  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  /**
   * 菜单节点类型
   */
  interface MenuNode {
    id?: number
    name?: string
    label?: string
    meta?: {
      title?: string
      authList?: Array<{
        id: number
        authMark: string
        title: string
        checked?: boolean
      }>
    }
    children?: MenuNode[]
    [key: string]: any
  }

  /**
   * 处理菜单数据，将 authList 转换为树形子节点
   * 递归处理菜单树，将权限列表展开为可选择的子节点
   */
  const processedMenuList = computed(() => {
    const processNode = (node: MenuNode): MenuNode => {
      const processed = { ...node }

      // 如果有 authList，将其转换为子节点
      if (node.meta?.authList?.length) {
        const authNodes = node.meta.authList.map((auth) => ({
          id: auth.id as unknown as number,
          name: `${node.name}_${auth.authMark}`,
          label: auth.title,
          authMark: auth.authMark,
          isAuth: true,
          checked: auth.checked || false
        }))

        processed.children = processed.children ? [...processed.children, ...authNodes] : authNodes
      }

      // 递归处理子节点
      if (processed.children) {
        processed.children = processed.children.map(processNode)
      }

      return processed
    }

    return (menuList.value as any[]).map(processNode)
  })

  /**
   * 树形组件配置
   */
  const defaultProps = {
    children: 'children',
    label: (data: any) => formatMenuTitle(data.meta?.title) || data.label || ''
  }

  /**
   * 监听弹窗打开，初始化权限数据
   */
  watch(
    () => props.modelValue,
    async (newVal) => {
      if (newVal) {
        // 每次弹窗打开时加载菜单数据
        await getMenuList()
        if (props.roleData) {
          console.log('设置权限:', props.roleData)
          const menuIds = (props.roleData as any).menu_ids
          console.log('menu_ids:', menuIds)
          // 根据当前的menu_ids设置选中状态
          await setCheckedMenuIds(menuIds)
        }
      }
    }
  )

  /**
   * 根据menu_ids设置树形组件的选中状态
   * @param menuIds 菜单ID数组
   */
  const setCheckedMenuIds = async (menuIds?: string[] | number[]) => {
    if (!menuIds || !menuIds.length || !treeRef.value) return

    // 等待DOM更新，确保树组件已渲染完成
    await nextTick()

    // 获取所有树节点的name与id映射
    const idToNameMap = new Map<string | number, string>()

    // 递归遍历所有节点，建立id到name的映射
    const buildIdNameMap = (nodes: MenuNode[]) => {
      nodes.forEach((node) => {
        if (node.id) {
          idToNameMap.set(node.id, node.name as string)
        }
        if (node.children?.length) {
          buildIdNameMap(node.children)
        }
      })
    }
    // 构建映射关系
    buildIdNameMap(processedMenuList.value)
    // 将menu_ids转换为对应的name数组
    const checkedNames = menuIds
      .filter((id) => idToNameMap.has(id))
      .map((id) => idToNameMap.get(id) as string)
    // 设置选中状态
    treeRef.value.setCheckedKeys(checkedNames)
    // 更新全选状态
    handleTreeCheck()
  }

  /**
   * 关闭弹窗并清空选中状态
   */
  const handleClose = () => {
    visible.value = false
    treeRef.value?.setCheckedKeys([])
  }

  /**
   * 保存权限配置
   */
  const savePermission = () => {
    // TODO: 调用保存权限接口
    const selectedKeys = outputSelectedData()
    // console.log('设置权限:', props.roleData)
    // console.log('=== 选中的权限数据 ===', selectedKeys)
    const params = { menu_ids: selectedKeys }
    updateRoleApi((props.roleData as any)?.id, params)
      .then(() => {
        ElMessage.success('权限保存成功')
        emit('success')
        handleClose()
      })
      .catch((error: any) => {
        console.error('保存权限失败:', error)
        ElMessage.error('保存权限失败')
      })
  }

  /**
   * 切换全部展开/收起状态
   */
  const toggleExpandAll = () => {
    const tree = treeRef.value
    if (!tree) return

    const nodes = tree.store.nodesMap
    // 这里保留 any，因为 Element Plus 的内部节点类型较复杂
    Object.values(nodes).forEach((node: any) => {
      node.expanded = !isExpandAll.value
    })

    isExpandAll.value = !isExpandAll.value
  }

  /**
   * 切换全选/取消全选状态
   */
  const toggleSelectAll = () => {
    const tree = treeRef.value
    if (!tree) return

    if (!isSelectAll.value) {
      const allKeys = getAllNodeKeys(processedMenuList.value)
      tree.setCheckedKeys(allKeys)
    } else {
      tree.setCheckedKeys([])
    }

    isSelectAll.value = !isSelectAll.value
  }

  /**
   * 递归获取所有节点的 key
   * @param nodes 节点列表
   * @returns 所有节点的 key 数组
   */
  const getAllNodeKeys = (nodes: MenuNode[]): string[] => {
    const keys: string[] = []
    const traverse = (nodeList: MenuNode[]): void => {
      nodeList.forEach((node) => {
        if (node.name) keys.push(node.name)
        if (node.children?.length) traverse(node.children)
      })
    }
    traverse(nodes)
    return keys
  }

  /**
   * 处理树节点选中状态变化
   * 同步更新全选按钮状态
   */
  const handleTreeCheck = () => {
    const tree = treeRef.value
    if (!tree) return

    const checkedKeys = tree.getCheckedKeys()
    const allKeys = getAllNodeKeys(processedMenuList.value)

    isSelectAll.value = checkedKeys.length === allKeys.length && allKeys.length > 0
  }

  /**
   * 输出选中的权限数据到控制台
   * 用于调试和查看当前选中的权限配置
   */
  const outputSelectedData = () => {
    const tree = treeRef.value
    if (!tree) return
    const keys: string[] = []
    const checkedNodes = tree.getCheckedNodes()
    checkedNodes.forEach((node: { id: any }) => {
      keys.push(node.id || '')
    })
    return keys
    // console.log('=== 选中的权限数据 ===', keys)
    // console.log('=== 选中的权限数据 ===', selectedData)
    // ElMessage.success(`已输出选中数据到控制台，共选中 ${checkedNodes.length} 个节点`)
  }
</script>
