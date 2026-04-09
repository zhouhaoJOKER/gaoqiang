<!-- 文档页签 - QQ文档风格布局 -->
<template>
  <div class="document-container">
    <!-- 左侧目录面板 -->
    <div class="document-sidebar" :class="{ collapsed: sidebarCollapsed }">
      <div class="sidebar-header">
        <span v-if="!sidebarCollapsed" class="sidebar-title">
          <ArtSvgIcon icon="ri:menu-line" class="mr-2" />
          目录
        </span>
        <div class="sidebar-actions">
          <ElButton v-if="!sidebarCollapsed" text size="small" @click="handleCreateDocument">
            <ArtSvgIcon icon="ri:add-line" />
          </ElButton>
          <ElButton text size="small" @click="sidebarCollapsed = !sidebarCollapsed">
            <ArtSvgIcon :icon="sidebarCollapsed ? 'ri:menu-unfold-line' : 'ri:menu-fold-line'" />
          </ElButton>
        </div>
      </div>

      <!-- 目录树 -->
      <div v-if="!sidebarCollapsed" class="document-tree">
        <ElTree
          ref="treeRef"
          :data="documentTree"
          :props="treeProps"
          node-key="id"
          :current-node-key="currentDocId"
          :expand-on-click-node="false"
          highlight-current
          default-expand-all
          @node-click="handleNodeClick"
        >
          <template #default="{ node, data }">
            <div class="tree-node">
              <ArtSvgIcon
                :icon="data.kind === 0 ? 'ri:folder-line' : 'ri:file-text-line'"
                class="node-icon"
              />
              <span class="node-label">{{ node.label }}</span>
              <div class="node-actions">
                <ElDropdown
                  trigger="click"
                  @command="(cmd: string) => handleNodeCommand(cmd, data)"
                >
                  <span class="actions-trigger" @click.stop>
                    <ArtSvgIcon icon="ri:more-fill" />
                  </span>
                  <template #dropdown>
                    <ElDropdownMenu>
                      <ElDropdownItem command="rename">
                        <ArtSvgIcon icon="ri:edit-line" class="mr-2" />
                        重命名
                      </ElDropdownItem>
                      <ElDropdownItem command="delete">
                        <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2 text-red-500" />
                        <span class="text-red-500">删除</span>
                      </ElDropdownItem>
                    </ElDropdownMenu>
                  </template>
                </ElDropdown>
                <span
                  v-if="data.kind === 0"
                  class="actions-trigger add-btn"
                  @click.stop="handleAddChild(data)"
                >
                  <ArtSvgIcon icon="ri:add-line" />
                </span>
              </div>
            </div>
          </template>
        </ElTree>

        <!-- 快捷操作 -->
        <div class="tree-actions">
          <div class="action-item" @click="handleCreateFolder">
            <ArtSvgIcon icon="ri:folder-add-line" class="mr-2" />
            新建文件夹
          </div>
          <div class="action-item" @click="handleCreateDocument">
            <ArtSvgIcon icon="ri:file-add-line" class="mr-2" />
            新建文档
          </div>
        </div>

        <!-- 底部快捷入口 -->
        <div class="sidebar-footer">
          <div class="footer-item">
            <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2" />
            最近删除
          </div>
          <div class="footer-item">
            <ArtSvgIcon icon="ri:settings-3-line" class="mr-2" />
            设置
          </div>
        </div>
      </div>
    </div>

    <!-- 右侧编辑面板 -->
    <div class="document-content">
      <template v-if="currentDocument">
        <!-- 文件夹视图 -->
        <template v-if="currentDocument.kind === 0">
          <div class="folder-view">
            <div class="folder-body">
              <div class="folder-paper">
                <!-- 文件夹头部 -->
                <div class="folder-header">
                  <div class="folder-info">
                    <div class="folder-icon-large">
                      <ArtSvgIcon icon="ri:folder-fill" />
                    </div>
                    <div class="folder-details">
                      <h1 class="folder-title">{{ currentDocument.name }}</h1>
                      <div
                        class="folder-description"
                        :class="{ empty: !currentDocument.description }"
                        @click="handleEditFolderDescription"
                      >
                        {{ currentDocument.description || '点击添加备注' }}
                      </div>
                    </div>
                  </div>
                  <div class="folder-actions">
                    <ElButton type="primary" @click="handleAddContent">
                      <ArtSvgIcon icon="ri:add-circle-line" class="mr-1" />
                      添加内容
                    </ElButton>
                  </div>
                </div>

                <ElDivider />

                <!-- 统计信息 -->
                <div class="folder-stats">{{ folderStatsText }}</div>

                <!-- 子项列表 -->
                <div class="folder-children">
                  <div
                    v-for="child in folderChildren"
                    :key="child.id"
                    class="child-item"
                    @click="handleNodeClick(child)"
                  >
                    <div class="child-icon" :class="child.kind === 0 ? 'folder' : 'document'">
                      <ArtSvgIcon
                        :icon="child.kind === 0 ? 'ri:folder-fill' : 'ri:file-text-line'"
                      />
                    </div>
                    <div class="child-info">
                      <div class="child-name">{{ child.name }}</div>
                      <div v-if="child.kind === 1 && child.description" class="child-description">
                        {{ child.description }}
                      </div>
                      <div class="child-meta">
                        {{ getChildMeta(child) }}
                      </div>
                    </div>
                    <ElDropdown
                      trigger="click"
                      class="child-actions"
                      @command="(cmd: string) => handleNodeCommand(cmd, child)"
                    >
                      <span class="actions-trigger" @click.stop>
                        <ArtSvgIcon icon="ri:more-line" />
                      </span>
                      <template #dropdown>
                        <ElDropdownMenu>
                          <ElDropdownItem command="rename">
                            <ArtSvgIcon icon="ri:edit-line" class="mr-2" />
                            重命名
                          </ElDropdownItem>
                          <ElDropdownItem command="delete" divided>
                            <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2" />
                            删除
                          </ElDropdownItem>
                        </ElDropdownMenu>
                      </template>
                    </ElDropdown>
                  </div>

                  <!-- 空状态 -->
                  <div v-if="folderChildren.length === 0" class="folder-empty">
                    <ArtSvgIcon icon="ri:folder-open-line" class="empty-folder-icon" />
                    <p>文件夹为空</p>
                    <ElButton type="primary" size="small" @click="handleAddContent">
                      添加内容
                    </ElButton>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </template>

        <!-- 文档编辑视图 -->
        <template v-else>
          <!-- 文档头部工具栏 -->
          <div class="document-header">
            <div class="header-left">
              <ElButton
                v-if="sidebarCollapsed"
                text
                size="small"
                class="toggle-sidebar-btn"
                @click="sidebarCollapsed = false"
              >
                <ArtSvgIcon icon="ri:menu-unfold-line" />
              </ElButton>
              <div class="header-breadcrumb">
                <span
                  v-for="(item, index) in breadcrumbs"
                  :key="item.id"
                  class="breadcrumb-item"
                  @click="handleBreadcrumbClick(item)"
                >
                  {{ item.name }}
                  <ArtSvgIcon
                    v-if="index < breadcrumbs.length - 1"
                    icon="ri:arrow-right-s-line"
                    class="breadcrumb-separator"
                  />
                </span>
              </div>
              <span class="sync-status" :class="syncStatusClass">
                <ArtSvgIcon
                  :icon="syncStatusIcon"
                  class="sync-icon"
                  :class="{ spinning: isSyncing }"
                />
                {{ syncStatusText }}
                <span v-if="lastSyncTime && !isEditing && !isSyncing" class="sync-time">
                  {{ lastSyncTime }}
                </span>
              </span>
            </div>
            <div class="header-actions">
              <ElTooltip content="邀请协作" placement="bottom">
                <ElButton class="action-btn invite-btn" size="small">
                  <ArtSvgIcon icon="ri:user-add-line" class="mr-1" />
                  邀请
                </ElButton>
              </ElTooltip>
              <ElTooltip content="分享" placement="bottom">
                <ElButton text size="small" class="icon-btn">
                  <ArtSvgIcon icon="ri:share-line" />
                </ElButton>
              </ElTooltip>
              <ElTooltip content="提醒" placement="bottom">
                <ElButton text size="small" class="icon-btn">
                  <ArtSvgIcon icon="ri:notification-line" />
                </ElButton>
              </ElTooltip>
              <ElTooltip content="复制链接" placement="bottom">
                <ElButton text size="small" class="icon-btn">
                  <ArtSvgIcon icon="ri:link-m" />
                </ElButton>
              </ElTooltip>
              <ElDropdown>
                <ElButton text size="small" class="icon-btn">
                  <ArtSvgIcon icon="ri:more-line" />
                </ElButton>
                <template #dropdown>
                  <ElDropdownMenu>
                    <ElDropdownItem>
                      <ArtSvgIcon icon="ri:download-line" class="mr-2" />
                      导出
                    </ElDropdownItem>
                    <ElDropdownItem>
                      <ArtSvgIcon icon="ri:history-line" class="mr-2" />
                      历史版本
                    </ElDropdownItem>
                    <ElDropdownItem divided>
                      <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2" />
                      删除
                    </ElDropdownItem>
                  </ElDropdownMenu>
                </template>
              </ElDropdown>
            </div>
          </div>

          <!-- 文档编辑主体区域 -->
          <div class="document-body">
            <div class="document-paper">
              <!-- 文档标题 -->
              <div class="document-title-section">
                <textarea
                  ref="titleInputRef"
                  v-model="currentDocument.name"
                  class="title-textarea"
                  placeholder="无标题文档"
                  rows="1"
                  @blur="handleTitleUpdate"
                  @input="autoResizeTitle"
                  @keydown.enter.prevent="focusEditor"
                />
              </div>

              <!-- 富文本编辑器 - 使用悬浮工具栏 -->
              <div class="document-editor">
                <ArtWangEditor
                  :key="`editor-${currentDocId}`"
                  ref="editorRef"
                  v-model="documentContent"
                  :height="editorHeight"
                  :toolbar-keys="editorToolbarKeys"
                  placeholder="开始输入内容..."
                  @focus="handleEditorFocus"
                  @blur="handleEditorBlur"
                  @change="handleEditorChange"
                />
              </div>
            </div>

            <!-- 右侧大纲面板 -->
            <div v-if="documentOutline.length > 0" class="document-outline">
              <div class="outline-header">
                <span class="outline-title">{{ currentDocument?.name || '文档大纲' }}</span>
                <ElButton
                  text
                  size="small"
                  class="outline-collapse-btn"
                  @click="outlineCollapsed = !outlineCollapsed"
                >
                  <ArtSvgIcon
                    :icon="
                      outlineCollapsed ? 'ri:arrow-left-double-line' : 'ri:arrow-right-double-line'
                    "
                  />
                </ElButton>
              </div>
              <div v-if="!outlineCollapsed" class="outline-list">
                <div
                  v-for="(item, index) in documentOutline"
                  :key="index"
                  class="outline-item"
                  :class="[`level-${item.level}`, { active: activeOutlineIndex === index }]"
                  @click="scrollToHeading(item)"
                >
                  <span class="outline-dot"></span>
                  <span class="outline-text">{{ item.text }}</span>
                </div>
              </div>
            </div>
          </div>
        </template>
      </template>

      <!-- 空状态 -->
      <div v-else class="empty-state">
        <div class="empty-content">
          <div class="empty-icon-wrapper">
            <ArtSvgIcon icon="ri:file-text-line" class="empty-icon" />
          </div>
          <h3 class="empty-title">开始创建文档</h3>
          <p class="empty-text">选择左侧已有文档或创建新文档</p>
          <div class="empty-actions">
            <ElButton type="primary" size="large" @click="handleCreateDocument">
              <ArtSvgIcon icon="ri:add-line" class="mr-1" />
              新建文档
            </ElButton>
            <ElButton size="large" @click="handleCreateFolder">
              <ArtSvgIcon icon="ri:folder-add-line" class="mr-1" />
              新建文件夹
            </ElButton>
          </div>
        </div>
      </div>
    </div>

    <!-- 新建文档弹窗 -->
    <ElDialog v-model="createDialogVisible" title="新建文档" width="400px">
      <ElForm :model="createForm" label-width="80px">
        <ElFormItem label="文档名称">
          <ElInput v-model="createForm.name" placeholder="请输入文档名称" />
        </ElFormItem>
        <ElFormItem label="文档类型">
          <ElRadioGroup v-model="createForm.kind">
            <ElRadio :value="1">文档</ElRadio>
            <ElRadio :value="0">文件夹</ElRadio>
          </ElRadioGroup>
        </ElFormItem>
        <ElFormItem label="上级目录">
          <ElTreeSelect
            v-model="createForm.parent_id"
            :data="folderTree"
            :props="{ label: 'name', value: 'id' }"
            placeholder="请选择上级目录（可选）"
            clearable
            check-strictly
          />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="createDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="creating" @click="handleSubmitCreate"> 确定 </ElButton>
      </template>
    </ElDialog>

    <!-- 重命名弹窗 -->
    <ElDialog v-model="renameDialogVisible" title="重命名" width="400px">
      <ElInput v-model="renameForm.name" placeholder="请输入新名称" />
      <template #footer>
        <ElButton @click="renameDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="renaming" @click="handleSubmitRename"> 确定 </ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import '@wangeditor/editor/dist/css/style.css' // 引入 css

  import { ref, reactive, computed, onMounted, inject, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtWangEditor from '@/components/core/forms/art-wang-editor/index.vue'
  import {
    listPmDocumentTreeApi,
    viewPmDocumentApi,
    createPmDocumentApi,
    updatePmDocumentApi,
    deletePmDocumentApi
  } from '@/api/pm/document'

  interface DocumentItem {
    id: string | number
    name: string
    content?: string // 内容，详情接口返回
    description?: string
    kind: number // 0: 文件夹, 1: 文档
    py?: string // 拼音缩写
    is_public?: boolean | null
    parent_id?: string | number | null
    children?: DocumentItem[]
    [key: string]: any
  }

  // 注入项目数据
  const projectData = inject<any>('projectData')

  // 状态
  const loading = ref(false)
  const creating = ref(false)
  const renaming = ref(false)
  const isSyncing = ref(false)
  const isEditing = ref(false)
  const lastSyncTime = ref('')
  const documentList = ref<DocumentItem[]>([])
  const currentDocId = ref<string | number | undefined>(undefined)
  const currentDocument = ref<DocumentItem | null>(null)
  const treeRef = ref()
  const titleInputRef = ref<HTMLTextAreaElement>()
  const editorRef = ref()
  const sidebarCollapsed = ref(false)
  const outlineCollapsed = ref(false)
  const activeOutlineIndex = ref(-1)

  // 文档大纲
  interface OutlineItem {
    level: number
    text: string
    element?: HTMLElement
  }
  const documentOutline = ref<OutlineItem[]>([])

  // 目录树配置
  const treeProps = {
    label: 'name',
    children: 'children'
  }

  // 计算目录树（API 已返回树状结构）
  const documentTree = computed(() => {
    return documentList.value
  })

  // 仅文件夹的树（递归过滤）
  const folderTree = computed(() => {
    const filterFolders = (items: DocumentItem[]): DocumentItem[] => {
      return items
        .filter((item) => item.kind === 0)
        .map((item) => ({
          ...item,
          children: item.children ? filterFolders(item.children) : []
        }))
    }
    return filterFolders(documentList.value)
  })

  // 当前文件夹的子项
  const folderChildren = computed(() => {
    if (!currentDocument.value || currentDocument.value.kind !== 0) return []
    return currentDocument.value.children || []
  })

  // 文件夹子项统计
  const folderChildrenStats = computed(() => {
    const children = folderChildren.value
    const folderCount = children.filter((c) => c.kind === 0).length
    const docCount = children.filter((c) => c.kind === 1).length
    return { folderCount, docCount }
  })

  // 文件夹统计文本
  const folderStatsText = computed(() => {
    const { folderCount, docCount } = folderChildrenStats.value
    return `${folderCount} 个文件夹，${docCount} 篇文档`
  })

  // 面包屑
  const breadcrumbs = computed(() => {
    if (!currentDocument.value) return []
    const crumbs: DocumentItem[] = []
    let current: DocumentItem | null = currentDocument.value
    while (current) {
      crumbs.unshift(current)
      if (current.parent_id) {
        current = findDocumentById(documentList.value, current.parent_id)
      } else {
        break
      }
    }
    return crumbs
  })

  // 文档内容（双向绑定）
  const documentContent = computed({
    get: () => currentDocument.value?.content || '',
    set: (val: string) => {
      if (currentDocument.value) {
        currentDocument.value.content = val
      }
    }
  })

  // 同步状态文本
  const syncStatusText = computed(() => {
    if (isSyncing.value) return '同步中'
    if (isEditing.value) return '编辑中'
    return '已同步'
  })

  // 同步状态图标
  const syncStatusIcon = computed(() => {
    if (isSyncing.value) return 'ri:loader-4-line'
    if (isEditing.value) return 'ri:edit-line'
    return 'ri:check-line'
  })

  // 同步状态样式类
  const syncStatusClass = computed(() => {
    if (isSyncing.value) return 'syncing'
    if (isEditing.value) return 'editing'
    return 'synced'
  })

  // 格式化时间
  const formatSyncTime = (): string => {
    const now = new Date()
    const hours = now.getHours().toString().padStart(2, '0')
    const minutes = now.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  }

  // 编辑器高度
  const editorHeight = computed(() => 'calc(100vh - 25px)')

  // 编辑器工具栏
  const editorToolbarKeys = [
    'headerSelect',
    'bold',
    'italic',
    'underline',
    'through',
    '|',
    'bulletedList',
    'numberedList',
    'todo',
    '|',
    'insertLink',
    'uploadImage',
    'insertTable',
    '|',
    'codeBlock',
    'blockquote',
    '|',
    'undo',
    'redo'
  ]

  // 新建弹窗
  const createDialogVisible = ref(false)
  const createForm = reactive({
    name: '',
    kind: 1 as number, // 0: 文件夹, 1: 文档
    parent_id: null as string | number | null
  })

  // 重命名弹窗
  const renameDialogVisible = ref(false)
  const renameForm = reactive({
    id: null as string | number | null,
    name: ''
  })

  /**
   * 构建树结构
   */
  // buildTree 已不再需要，API 直接返回树状结构

  /**
   * 加载文档树状列表
   */
  const loadDocuments = async (): Promise<void> => {
    if (!projectData?.id) return
    loading.value = true
    try {
      const res = await listPmDocumentTreeApi({ 'q[project_id_eq]': projectData.id })
      documentList.value = (res as any).data || []

      // 如果当前选中的文档不存在，清空选中
      if (currentDocId.value) {
        const exists = findDocumentById(documentList.value, currentDocId.value)
        if (!exists) {
          currentDocId.value = undefined
          currentDocument.value = null
        }
      }
    } catch (error) {
      console.error('加载文档失败:', error)
      ElMessage.error('加载文档失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 在树状结构中查找文档
   */
  const findDocumentById = (list: DocumentItem[], id: string | number): DocumentItem | null => {
    for (const item of list) {
      if (item.id === id) return item
      if (item.children && item.children.length > 0) {
        const found = findDocumentById(item.children, id)
        if (found) return found
      }
    }
    return null
  }

  /**
   * 处理节点点击
   */
  const handleNodeClick = async (data: DocumentItem): Promise<void> => {
    currentDocId.value = data.id

    // 获取文档详情
    try {
      const res = await viewPmDocumentApi({ id: data.id })
      const detail = (res as any).data || data
      currentDocument.value = { ...detail }

      // 如果是文档，提取大纲
      if (detail.kind === 1) {
        setTimeout(() => extractOutline(), 100)
      } else {
        documentOutline.value = []
      }
    } catch (error) {
      console.error('获取文档详情失败:', error)
      // 降级使用树状数据
      currentDocument.value = { ...data }
      if (data.kind === 1) {
        setTimeout(() => extractOutline(), 100)
      } else {
        documentOutline.value = []
      }
    }
  }

  /**
   * 获取子项元信息
   */
  const getChildMeta = (child: DocumentItem): string => {
    if (child.kind === 0) {
      // 文件夹：统计子文档数量
      const childCount = documentList.value.filter((d) => d.parent_id === child.id).length
      return `${childCount} 篇文档`
    } else {
      // 文档：显示子文档数量
      const childCount = documentList.value.filter((d) => d.parent_id === child.id).length
      return childCount > 0 ? `${childCount} 篇子文档` : ''
    }
  }

  /**
   * 编辑文件夹描述
   */
  const handleEditFolderDescription = async (): Promise<void> => {
    if (!currentDocument.value) return
    // TODO: 可以弹窗编辑或直接内联编辑
  }

  /**
   * 添加内容到文件夹
   */
  const handleAddContent = (): void => {
    if (currentDocument.value) {
      createForm.parent_id = currentDocument.value.id
    }
    createDialogVisible.value = true
  }

  /**
   * 处理节点操作
   */
  const handleNodeCommand = (command: string, data: DocumentItem): void => {
    switch (command) {
      case 'rename':
        renameForm.id = data.id
        renameForm.name = data.name
        renameDialogVisible.value = true
        break
      case 'delete':
        handleDeleteDocument(data)
        break
    }
  }

  /**
   * 添加子文档/文件夹
   */
  const handleAddChild = (data: DocumentItem): void => {
    createForm.parent_id = data.id
    createDialogVisible.value = true
  }

  /**
   * 创建文档
   */
  const handleCreateDocument = (): void => {
    createForm.name = ''
    createForm.kind = 1 // 文档
    createForm.parent_id = null
    createDialogVisible.value = true
  }

  /**
   * 创建文件夹
   */
  const handleCreateFolder = (): void => {
    createForm.name = ''
    createForm.kind = 0 // 文件夹
    createForm.parent_id = null
    createDialogVisible.value = true
  }

  /**
   * 提交创建
   */
  const handleSubmitCreate = async (): Promise<void> => {
    if (!createForm.name.trim()) {
      ElMessage.warning('请输入名称')
      return
    }

    creating.value = true
    try {
      await createPmDocumentApi({
        project_id: projectData?.id,
        name: createForm.name,
        kind: createForm.kind, // 0: 文件夹, 1: 文档
        parent_id: createForm.parent_id || null,
        content: ''
      })
      ElMessage.success('创建成功')
      createDialogVisible.value = false
      await loadDocuments()
    } catch (error) {
      console.error('创建失败:', error)
      ElMessage.error('创建失败')
    } finally {
      creating.value = false
    }
  }

  /**
   * 提交重命名
   */
  const handleSubmitRename = async (): Promise<void> => {
    if (!renameForm.name.trim()) {
      ElMessage.warning('请输入名称')
      return
    }

    renaming.value = true
    try {
      await updatePmDocumentApi(String(renameForm.id), {
        name: renameForm.name
      })
      ElMessage.success('重命名成功')
      renameDialogVisible.value = false
      await loadDocuments()
    } catch (error) {
      console.error('重命名失败:', error)
      ElMessage.error('重命名失败')
    } finally {
      renaming.value = false
    }
  }

  /**
   * 删除文档
   */
  const handleDeleteDocument = async (data: DocumentItem): Promise<void> => {
    try {
      await ElMessageBox.confirm(
        `确定要删除${data.kind === 0 ? '文件夹' : '文档'}"${data.name}"吗？`,
        '确认删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      await deletePmDocumentApi(Number(data.id))
      ElMessage.success('删除成功')
      if (currentDocId.value === data.id) {
        currentDocId.value = undefined
        currentDocument.value = null
      }
      await loadDocuments()
    } catch (error: any) {
      if (error !== 'cancel') {
        console.error('删除失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 更新标题
   */
  const handleTitleUpdate = async (): Promise<void> => {
    if (!currentDocument.value) return
    try {
      await updatePmDocumentApi(String(currentDocument.value.id), {
        name: currentDocument.value.name
      })
      await loadDocuments()
    } catch (error) {
      console.error('更新标题失败:', error)
      ElMessage.error('更新标题失败')
    }
  }

  /**
   * 自动调整标题高度
   */
  const autoResizeTitle = (): void => {
    const textarea = titleInputRef.value
    if (textarea) {
      textarea.style.height = 'auto'
      textarea.style.height = textarea.scrollHeight + 'px'
    }
  }

  /**
   * 聚焦编辑器
   */
  const focusEditor = (): void => {
    // 在标题按回车时聚焦到编辑器
    if (editorRef.value) {
      editorRef.value.focus?.()
    }
  }

  /**
   * 提取文档大纲
   */
  const extractOutline = (): void => {
    const content = currentDocument.value?.content || ''
    const outline: OutlineItem[] = []

    // 解析 HTML 内容中的标题
    const parser = new DOMParser()
    const doc = parser.parseFromString(content, 'text/html')
    const headings = doc.querySelectorAll('h1, h2, h3, h4, h5, h6')

    headings.forEach((heading) => {
      const level = parseInt(heading.tagName.substring(1))
      const text = heading.textContent?.trim() || ''
      if (text) {
        outline.push({ level, text })
      }
    })

    documentOutline.value = outline
  }

  /**
   * 滚动到指定标题
   */
  const scrollToHeading = (item: OutlineItem): void => {
    const index = documentOutline.value.indexOf(item)
    activeOutlineIndex.value = index

    // 在编辑器中查找对应的标题元素
    const editorContainer = document.querySelector('.document-editor .w-e-text-container')
    if (editorContainer) {
      const headings = Array.from(editorContainer.querySelectorAll('h1, h2, h3, h4, h5, h6'))
      let headingIndex = 0
      for (const heading of headings) {
        if (heading.textContent?.trim() === item.text) {
          if (
            headingIndex === index ||
            documentOutline.value.filter((o, i) => i < index && o.text === item.text).length ===
              headingIndex
          ) {
            heading.scrollIntoView({ behavior: 'smooth', block: 'start' })
            break
          }
          headingIndex++
        }
      }
    }
  }

  /**
   * 更新内容
   */
  /**
   * 编辑器获得焦点
   */
  const handleEditorFocus = (): void => {
    isEditing.value = true
  }

  /**
   * 编辑器失去焦点
   */
  const handleEditorBlur = (): void => {
    isEditing.value = false
    handleContentUpdate()
  }

  /**
   * 编辑器内容变化
   */
  const handleEditorChange = (): void => {
    extractOutline()
  }

  /**
   * 更新内容
   */
  const handleContentUpdate = async (): Promise<void> => {
    if (!currentDocument.value) return
    isSyncing.value = true
    try {
      await updatePmDocumentApi(String(currentDocument.value.id), {
        content: currentDocument.value.content
      })
      lastSyncTime.value = formatSyncTime()
    } catch (error) {
      console.error('更新内容失败:', error)
      ElMessage.error('保存失败')
    } finally {
      isSyncing.value = false
    }
  }

  /**
   * 面包屑点击
   */
  const handleBreadcrumbClick = (item: DocumentItem): void => {
    if (item.id !== currentDocId.value) {
      currentDocId.value = item.id
      currentDocument.value = { ...item }
    }
  }

  onMounted(() => {
    loadDocuments()
  })

  // 监听项目数据变化，确保刷新时能加载数据
  watch(
    () => projectData?.id,
    (newId) => {
      if (newId && documentList.value.length === 0) {
        loadDocuments()
      }
    },
    { immediate: true }
  )

  // 防抖定时器
  let saveTimer: ReturnType<typeof setTimeout> | null = null

  // 监听内容变化，自动保存（防抖）
  watch(
    () => currentDocument.value?.content,
    (newContent, oldContent) => {
      // 仅当内容真正变化时保存
      if (currentDocument.value?.id && oldContent !== undefined && newContent !== oldContent) {
        // 清除之前的定时器
        if (saveTimer) {
          clearTimeout(saveTimer)
        }
        // 延迟2.5秒保存，防止频繁调用
        saveTimer = setTimeout(() => {
          handleContentUpdate()
        }, 2500)
      }
    }
  )
</script>

<style scoped lang="scss">
  @reference '@styles/core/tailwind.css';

  .document-container {
    display: flex;
    height: 100%;
    overflow: hidden;
    background: #f5f6f7;
  }

  // 左侧边栏
  .document-sidebar {
    display: flex;
    flex-direction: column;
    width: 220px;
    min-width: 200px;
    background: #fff;
    border-right: 1px solid #e8e8e8;
    transition: all 0.3s ease;

    &.collapsed {
      width: 0;
      min-width: 0;
    }
  }

  .sidebar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 48px;
    padding: 12px 16px;
    border-bottom: 1px solid #e8e8e8;
  }

  .sidebar-title {
    display: flex;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    color: #1f2329;
  }

  .sidebar-actions {
    display: flex;
    gap: 4px;
    align-items: center;
  }

  .document-tree {
    flex: 1;
    padding: 8px 0;
    overflow-y: auto;
  }

  .tree-node {
    display: flex;
    align-items: center;
    width: 100%;
    padding-right: 8px;
  }

  .node-icon {
    margin-right: 8px;
    font-size: 16px;
    color: #646a73;
  }

  .node-label {
    flex: 1;
    overflow: hidden;
    font-size: 14px;
    color: #1f2329;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .node-actions {
    display: flex;
    gap: 2px;
    align-items: center;
    opacity: 0;
    transition: opacity 0.2s;
  }

  .tree-node:hover .node-actions {
    opacity: 1;
  }

  .actions-trigger {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 22px;
    height: 22px;
    color: #8f959e;
    cursor: pointer;
    border-radius: 4px;

    &:hover {
      color: #1f2329;
      background: #e8e9eb;
    }

    &.add-btn {
      color: #3370ff;

      &:hover {
        background: rgb(51 112 255 / 10%);
      }
    }
  }

  .tree-actions {
    padding: 12px 16px;
    margin-top: auto;
    border-top: 1px solid #e8e8e8;
  }

  .action-item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    font-size: 13px;
    color: #646a73;
    cursor: pointer;
    border-radius: 6px;
    transition: all 0.2s;

    &:hover {
      color: #3370ff;
      background: #f0f1f2;
    }
  }

  .sidebar-footer {
    padding: 8px 16px;
    border-top: 1px solid #e8e8e8;
  }

  .footer-item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    font-size: 13px;
    color: #646a73;
    cursor: pointer;
    border-radius: 6px;

    &:hover {
      background: #f0f1f2;
    }
  }

  // 右侧内容区
  .document-content {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
    overflow: hidden;
    background: #f5f6f7;
  }

  // 文档头部
  .document-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    min-height: 48px;
    padding: 8px 16px;
    background: #fff;
    border-bottom: 1px solid #e8e8e8;
  }

  .header-left {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .toggle-sidebar-btn {
    margin-right: 8px;
  }

  .header-breadcrumb {
    display: flex;
    gap: 4px;
    align-items: center;
    font-size: 13px;
    color: #646a73;
  }

  .breadcrumb-item {
    display: flex;
    align-items: center;
    padding: 4px 8px;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      color: #1f2329;
      background: #f0f1f2;
    }

    &:last-child {
      font-weight: 500;
      color: #1f2329;
    }
  }

  .breadcrumb-separator {
    margin: 0 2px;
    color: #bbbfc4;
  }

  .sync-status {
    display: flex;
    gap: 4px;
    align-items: center;
    padding: 4px 8px;
    margin-left: 8px;
    font-size: 12px;
    border-radius: 4px;
    transition: all 0.2s;

    &.synced {
      color: #34c759;
      background: rgb(52 199 89 / 10%);
    }

    &.editing {
      color: #ff9500;
      background: rgb(255 149 0 / 10%);
    }

    &.syncing {
      color: #007aff;
      background: rgb(0 122 255 / 10%);
    }

    .sync-icon {
      font-size: 12px;

      &.spinning {
        animation: spin 1s linear infinite;
      }
    }

    .sync-time {
      margin-left: 4px;
      font-size: 10px;
      color: #8c8c8c;
    }
  }

  @keyframes spin {
    from {
      transform: rotate(0deg);
    }

    to {
      transform: rotate(360deg);
    }
  }

  .header-actions {
    display: flex;
    gap: 4px;
    align-items: center;
  }

  .action-btn {
    border-radius: 6px;
  }

  .invite-btn {
    color: #fff;
    background: #3370ff;
    border: none;

    &:hover {
      background: #245bdb;
    }
  }

  .icon-btn {
    width: 32px;
    height: 32px;
    padding: 0;
    border-radius: 6px;

    &:hover {
      background: #f0f1f2;
    }
  }

  // 文件夹视图
  .folder-view {
    display: flex;
    flex: 1;
    flex-direction: column;
    height: 100%;
    overflow: hidden;
  }

  .folder-body {
    display: flex;
    flex: 1;
    align-items: flex-start;
    justify-content: center;
    height: 100%;
    padding: 24px;
    overflow-y: auto;
  }

  .folder-paper {
    width: 100%;
    max-width: 900px;
    min-height: calc(100% - 48px);
    padding: 48px 64px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 8%);
  }

  .folder-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
  }

  .folder-info {
    display: flex;
    gap: 20px;
    align-items: flex-start;
  }

  .folder-icon-large {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 64px;
    height: 64px;
    font-size: 48px;
    color: #3370ff;
  }

  .folder-details {
    flex: 1;
  }

  .folder-title {
    margin: 0 0 8px;
    font-size: 32px;
    font-weight: 700;
    line-height: 1.3;
    color: #1f2329;
  }

  .folder-description {
    padding: 4px 8px;
    margin: -4px -8px;
    font-size: 14px;
    color: #646a73;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      background: #f0f1f2;
    }

    &.empty {
      color: #bbbfc4;
    }
  }

  .folder-actions {
    flex-shrink: 0;
  }

  .folder-stats {
    margin-bottom: 20px;
    font-size: 14px;
    color: #646a73;
  }

  .folder-children {
    display: flex;
    flex-direction: column;
  }

  .child-item {
    display: flex;
    align-items: flex-start;
    padding: 20px 0;
    cursor: pointer;
    border-bottom: 1px solid #e8e8e8;
    transition: all 0.2s;

    &:hover {
      padding: 20px 24px;
      margin: 0 -24px;
      background: #f8f9fa;

      .child-actions {
        opacity: 1;
      }
    }

    &:last-child {
      border-bottom: none;
    }
  }

  .child-icon {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 56px;
    height: 56px;
    margin-right: 16px;
    font-size: 28px;
    border-radius: 8px;

    &.folder {
      color: #3370ff;
      background: #e8f3ff;
    }

    &.document {
      color: #646a73;
      background: #f0f1f2;
      border: 1px solid #e8e8e8;
    }
  }

  .child-info {
    flex: 1;
    min-width: 0;
  }

  .child-name {
    margin-bottom: 4px;
    font-size: 16px;
    font-weight: 500;
    color: #1f2329;
  }

  .child-description {
    margin-bottom: 4px;
    overflow: hidden;
    font-size: 14px;
    color: #646a73;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .child-meta {
    font-size: 13px;
    color: #8f959e;
  }

  .child-actions {
    margin-left: 12px;
    opacity: 0;
    transition: opacity 0.2s;
  }

  .folder-empty {
    padding: 60px 0;
    color: #8f959e;
    text-align: center;

    .empty-folder-icon {
      margin-bottom: 16px;
      font-size: 48px;
      color: #bbbfc4;
    }

    p {
      margin-bottom: 16px;
    }
  }

  // 文档主体
  .document-body {
    display: flex;
    flex: 1;
    gap: 16px;
    height: 100%;
    min-height: 0;
    overflow: hidden;
  }

  .document-paper {
    display: flex;
    flex: 1;
    flex-direction: column;
    padding: 24px 32px;
    overflow: hidden;
    background: #fff;
    box-shadow: 0 1px 4px rgb(0 0 0 / 8%);
  }

  // 文档标题
  .document-title-section {
    margin-bottom: 24px;
  }

  .title-textarea {
    width: 100%;
    overflow: hidden;
    font-size: 36px;
    font-weight: 700;
    line-height: 1.4;
    color: #1f2329;
    resize: none;
    background: transparent;
    border: none;
    outline: none;

    &::placeholder {
      color: #bbbfc4;
    }
  }

  .title-meta {
    display: flex;
    gap: 12px;
    align-items: center;
    padding-top: 12px;
    margin-top: 12px;
    border-top: 1px solid #e8e8e8;
  }

  .meta-item {
    display: flex;
    gap: 4px;
    align-items: center;
    font-size: 12px;
    color: #8f959e;

    .meta-icon {
      font-size: 14px;
    }
  }

  // 编辑器
  .document-editor {
    flex: 1;
    overflow: hidden auto;

    :deep(.w-e-text-container) {
      overflow: visible !important;
      background: transparent !important;
      border: none !important;
    }

    // 顶部固定工具栏
    :deep(.w-e-toolbar) {
      position: sticky !important;
      top: 0 !important;
      z-index: 50 !important;
      padding: 8px 0;
      padding-right: 32px;
      padding-left: 32px;
      margin: 0 -32px;
      background: #fff !important;
      border: none !important;
      border-bottom: 1px solid #e8e8e8 !important;
    }

    // 悬浮菜单样式调整
    :deep(.w-e-hover-bar) {
      z-index: 100 !important;
      background: #fff;
      border-radius: 4px;
      box-shadow: 0 2px 8px rgb(0 0 0 / 15%);
    }
  }

  // 右侧大纲面板
  .document-outline {
    flex-shrink: 0;
    width: 200px;
    min-width: 200px;
    padding: 16px 0 16px 16px;
    background: transparent;
  }

  .outline-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-right: 8px;
    margin-bottom: 12px;
  }

  .outline-title {
    max-width: 160px;
    overflow: hidden;
    font-size: 14px;
    font-weight: 500;
    color: #1890ff;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .outline-collapse-btn {
    padding: 2px !important;
    color: #8c8c8c;

    &:hover {
      color: #1890ff;
    }
  }

  .outline-list {
    padding-left: 0;
    border-left: 1px solid #e8e8e8;
  }

  .outline-item {
    position: relative;
    display: flex;
    align-items: center;
    padding: 6px 12px 6px 16px;
    font-size: 13px;
    color: #595959;
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
      color: #1890ff;
    }

    &.active {
      color: #1890ff;

      .outline-dot {
        background: #1890ff;
      }
    }

    &.level-1 {
      padding-left: 16px;
      font-weight: 500;
    }

    &.level-2 {
      padding-left: 28px;
    }

    &.level-3 {
      padding-left: 40px;
    }

    &.level-4,
    &.level-5,
    &.level-6 {
      padding-left: 52px;
    }
  }

  .outline-dot {
    flex-shrink: 0;
    width: 4px;
    height: 4px;
    margin-right: 8px;
    background: #d9d9d9;
    border-radius: 50%;
  }

  .outline-text {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  // 空状态
  .empty-state {
    display: flex;
    flex: 1;
    align-items: center;
    justify-content: center;
  }

  .empty-content {
    padding: 60px;
    text-align: center;
  }

  .empty-icon-wrapper {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 120px;
    height: 120px;
    margin: 0 auto 24px;
    background: linear-gradient(135deg, #e8f3ff 0%, #f0f5ff 100%);
    border-radius: 24px;
  }

  .empty-icon {
    font-size: 48px;
    color: #3370ff;
  }

  .empty-title {
    margin-bottom: 8px;
    font-size: 20px;
    font-weight: 600;
    color: #1f2329;
  }

  .empty-text {
    margin-bottom: 32px;
    font-size: 14px;
    color: #8f959e;
  }

  .empty-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
  }

  // 树节点样式
  :deep(.el-tree-node__content) {
    height: 36px;
    padding-left: 8px !important;
    margin: 0 8px;
    border-radius: 6px;

    &:hover {
      background: #f0f1f2;
    }
  }

  :deep(.el-tree-node.is-current > .el-tree-node__content) {
    color: #3370ff;
    background-color: #e8f3ff;

    .node-icon {
      color: #3370ff;
    }
  }

  // 弹窗样式优化
  :deep(.el-dialog) {
    border-radius: 12px;

    .el-dialog__header {
      padding: 20px 24px 16px;
      border-bottom: 1px solid #e8e8e8;
    }

    .el-dialog__body {
      padding: 24px;
    }

    .el-dialog__footer {
      padding: 16px 24px 20px;
      border-top: 1px solid #e8e8e8;
    }
  }
</style>
