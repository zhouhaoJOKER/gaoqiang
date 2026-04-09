<!-- 文件库页签 -->
<template>
  <div class="files-container">
    <!-- 顶部工具栏 -->
    <div class="files-toolbar">
      <div class="toolbar-left">
        <!-- 面包屑导航 -->
        <div class="breadcrumb">
          <span class="breadcrumb-item" @click="handleNavigate(null)"> 文件库 </span>
          <template v-for="(folder, index) in breadcrumbs" :key="folder.id">
            <ArtSvgIcon icon="ri:arrow-right-s-line" class="breadcrumb-separator" />
            <span
              class="breadcrumb-item"
              :class="{ active: index === breadcrumbs.length - 1 }"
              @click="handleNavigate(folder)"
            >
              {{ folder.name }}
            </span>
          </template>
        </div>
      </div>
      <div class="toolbar-right">
        <ElButton type="primary" @click="handleCreateFolder">
          <ArtSvgIcon icon="ri:folder-add-line" class="mr-1" />
          创建文件夹
        </ElButton>
        <ElUpload
          ref="uploadRef"
          :action="uploadUrl"
          :headers="uploadHeaders"
          :data="uploadData"
          :show-file-list="false"
          :before-upload="handleBeforeUpload"
          :on-success="handleUploadSuccess"
          :on-error="handleUploadError"
          multiple
        >
          <ElButton type="primary">
            <ArtSvgIcon icon="ri:upload-cloud-2-line" class="mr-1" />
            上传
          </ElButton>
        </ElUpload>
        <div class="view-switch">
          <ElButton text :class="{ active: viewMode === 'list' }" @click="viewMode = 'list'">
            <ArtSvgIcon icon="ri:list-check" />
          </ElButton>
          <ElButton text :class="{ active: viewMode === 'grid' }" @click="viewMode = 'grid'">
            <ArtSvgIcon icon="ri:grid-line" />
          </ElButton>
        </div>
      </div>
    </div>

    <!-- 文件列表 - 列表视图 -->
    <div v-if="viewMode === 'list'" class="files-list">
      <ElTable :data="fileList" style="width: 100%" @row-click="handleRowClick">
        <ElTableColumn width="50">
          <template #default>
            <ElCheckbox />
          </template>
        </ElTableColumn>
        <ElTableColumn prop="name" label="名称" min-width="300">
          <template #default="{ row }">
            <div class="file-name-cell">
              <div class="file-icon" :class="getFileIconClass(row)">
                <ArtSvgIcon :icon="getFileIcon(row)" />
              </div>
              <span class="file-name">{{ row.name }}</span>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="file_size" label="大小" width="120">
          <template #default="{ row }">
            {{ row.kind === 0 ? '-' : formatFileSize(row.file_size) }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="user_name" label="创建者" width="180">
          <template #default="{ row }">
            {{ row.user_name || row.user_email || '-' }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="updated_at" label="更新时间" width="180">
          <template #default="{ row }">
            {{ formatDate(row.updated_at) }}
          </template>
        </ElTableColumn>
        <ElTableColumn fixed="right" width="100">
          <template #default="{ row }">
            <div class="file-actions">
              <ElButton v-if="row.kind === 1" text size="small" @click.stop="handleDownload(row)">
                <ArtSvgIcon icon="ri:download-line" />
              </ElButton>
              <ElButton text size="small" @click.stop="handleRename(row)">
                <ArtSvgIcon icon="ri:edit-line" />
              </ElButton>
              <ElDropdown @command="(cmd: string) => handleFileCommand(cmd, row)">
                <ElButton text size="small" @click.stop>
                  <ArtSvgIcon icon="ri:more-line" />
                </ElButton>
                <template #dropdown>
                  <ElDropdownMenu>
                    <ElDropdownItem command="move">
                      <ArtSvgIcon icon="ri:folder-transfer-line" class="mr-2" />
                      移动
                    </ElDropdownItem>
                    <ElDropdownItem command="delete" divided>
                      <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2" />
                      删除
                    </ElDropdownItem>
                  </ElDropdownMenu>
                </template>
              </ElDropdown>
            </div>
          </template>
        </ElTableColumn>
      </ElTable>
    </div>

    <!-- 文件列表 - 网格视图 -->
    <div v-else class="files-grid">
      <div
        v-for="file in fileList"
        :key="file.id"
        class="file-card"
        @click="handleCardClick(file)"
        @dblclick="handleCardDblClick(file)"
      >
        <div class="card-icon" :class="getFileIconClass(file)">
          <ArtSvgIcon :icon="getFileIcon(file)" />
        </div>
        <div class="card-name" :title="file.name">{{ file.name }}</div>
        <div class="card-meta">
          {{ file.kind === 0 ? '-' : formatFileSize(file.file_size) }}
        </div>
        <ElDropdown class="card-actions" @command="(cmd: string) => handleFileCommand(cmd, file)">
          <span class="actions-trigger" @click.stop>
            <ArtSvgIcon icon="ri:more-line" />
          </span>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem command="download" :disabled="file.kind === 0"> 下载 </ElDropdownItem>
              <ElDropdownItem command="rename">重命名</ElDropdownItem>
              <ElDropdownItem command="delete" divided>删除</ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
      </div>

      <!-- 空状态 -->
      <div v-if="fileList.length === 0" class="empty-state">
        <ArtSvgIcon icon="ri:folder-open-line" class="empty-icon" />
        <p>暂无文件</p>
      </div>
    </div>

    <!-- 创建文件夹弹窗 -->
    <ElDialog v-model="createFolderDialogVisible" title="创建文件夹" width="400px">
      <ElInput v-model="newFolderName" placeholder="请输入文件夹名称" />
      <template #footer>
        <ElButton @click="createFolderDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="creating" @click="handleSubmitCreateFolder">
          确定
        </ElButton>
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

    <!-- 移动弹窗 -->
    <ElDialog v-model="moveDialogVisible" title="移动到" width="400px">
      <div class="move-dialog-content">
        <div class="move-tip">选择目标文件夹：</div>
        <div class="folder-tree">
          <div
            class="folder-item"
            :class="{ active: moveForm.targetParentId === null }"
            @click="moveForm.targetParentId = null"
          >
            <ArtSvgIcon icon="ri:folder-line" class="folder-icon" />
            <span>根目录</span>
          </div>
          <div
            v-for="folder in folderList"
            :key="folder.id"
            class="folder-item"
            :class="{
              active: moveForm.targetParentId === folder.id,
              disabled: folder.id === moveForm.id
            }"
            @click="folder.id !== moveForm.id && (moveForm.targetParentId = folder.id)"
          >
            <ArtSvgIcon icon="ri:folder-fill" class="folder-icon" />
            <span>{{ folder.name }}</span>
          </div>
        </div>
      </div>
      <template #footer>
        <ElButton @click="moveDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="moving" @click="handleSubmitMove"> 确定 </ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted, inject, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { listPmFileApi, createPmFileApi, updatePmFileApi, deletePmFileApi } from '@/api/pm/file'
  import { useUserStore } from '@/store/modules/user'

  interface FileItem {
    id: string | number
    name: string
    file_size?: number
    kind?: number // 0: 文件夹, 1: 文件
    parent_id?: string | number | null
    url?: string
    mime_type?: string
    user_name?: string
    user_email?: string
    updated_at?: string
    [key: string]: any
  }

  // 注入项目数据
  const projectData = inject<any>('projectData')
  const userStore = useUserStore()

  // 状态
  const loading = ref(false)
  const creating = ref(false)
  const renaming = ref(false)
  const viewMode = ref<'list' | 'grid'>('list')
  const fileList = ref<FileItem[]>([])
  const currentFolderId = ref<string | number | null>(null)
  const breadcrumbs = ref<FileItem[]>([])

  // 上传配置
  const uploadUrl = computed(() => '/api/v1/pm/files/upload')
  const uploadHeaders = computed(() => ({
    Authorization: `Bearer ${userStore.accessToken}`
  }))
  const uploadData = computed(() => ({
    project_id: projectData?.id,
    parent_id: currentFolderId.value || '',
    kind: 1 // 文件
  }))

  // 创建文件夹弹窗
  const createFolderDialogVisible = ref(false)
  const newFolderName = ref('')

  // 重命名弹窗
  const renameDialogVisible = ref(false)
  const renameForm = reactive({
    id: null as string | number | null,
    name: ''
  })

  // 移动弹窗
  const moveDialogVisible = ref(false)
  const moving = ref(false)
  const moveForm = reactive({
    id: null as string | number | null,
    name: '',
    targetParentId: null as string | number | null
  })
  const folderList = ref<FileItem[]>([])

  /**
   * 加载文件列表
   */
  const loadFiles = async (): Promise<void> => {
    if (!projectData?.id) return
    loading.value = true
    try {
      const params: any = { 'q[project_id_eq]': projectData.id }
      if (currentFolderId.value) {
        params['q[parent_id_eq]'] = currentFolderId.value
      } else {
        params['q[parent_id_null]'] = true
      }
      const res = await listPmFileApi(params)
      const data = (res as any).data || []
      // 排序：文件夹在上面，文件在下面
      fileList.value = data.sort((a: FileItem, b: FileItem) => {
        if (a.kind === 0 && b.kind !== 0) return -1
        if (a.kind !== 0 && b.kind === 0) return 1
        return 0
      })
    } catch (error) {
      console.error('加载文件失败:', error)
      ElMessage.error('加载文件失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 导航到文件夹
   */
  const handleNavigate = (folder: FileItem | null): void => {
    if (!folder) {
      currentFolderId.value = null
      breadcrumbs.value = []
    } else {
      currentFolderId.value = folder.id
      // 更新面包屑
      const idx = breadcrumbs.value.findIndex((b) => b.id === folder.id)
      if (idx >= 0) {
        breadcrumbs.value = breadcrumbs.value.slice(0, idx + 1)
      }
    }
    loadFiles()
  }

  /**
   * 行点击 - 进入文件夹
   */
  const handleRowClick = (row: FileItem): void => {
    if (row.kind === 0) {
      currentFolderId.value = row.id
      breadcrumbs.value.push(row)
      loadFiles()
    }
  }

  /**
   * 卡片点击
   */
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleCardClick = (file: FileItem): void => {
    // 单击选中 - 预留功能
  }

  /**
   * 卡片双击
   */
  const handleCardDblClick = (file: FileItem): void => {
    if (file.kind === 0) {
      currentFolderId.value = file.id
      breadcrumbs.value.push(file)
      loadFiles()
    } else {
      handlePreview(file)
    }
  }

  /**
   * 创建文件夹
   */
  const handleCreateFolder = (): void => {
    newFolderName.value = ''
    createFolderDialogVisible.value = true
  }

  /**
   * 提交创建文件夹
   */
  const handleSubmitCreateFolder = async (): Promise<void> => {
    if (!newFolderName.value.trim()) {
      ElMessage.warning('请输入文件夹名称')
      return
    }

    creating.value = true
    try {
      await createPmFileApi({
        project_id: projectData?.id,
        name: newFolderName.value,
        kind: 0, // 文件夹
        parent_id: currentFolderId.value || null
      })
      ElMessage.success('创建成功')
      createFolderDialogVisible.value = false
      await loadFiles()
    } catch (error) {
      console.error('创建失败:', error)
      ElMessage.error('创建失败')
    } finally {
      creating.value = false
    }
  }

  /**
   * 上传前处理
   */
  const handleBeforeUpload = (): boolean => {
    return true
  }

  /**
   * 上传成功
   */
  const handleUploadSuccess = (response: any): void => {
    if (response.success === 1) {
      ElMessage.success('上传成功')
      loadFiles()
    } else {
      ElMessage.error(response.msg || '上传失败')
    }
  }

  /**
   * 上传失败
   */
  const handleUploadError = (error: any): void => {
    const msg = error?.message || '上传失败'
    ElMessage.error(msg)
  }

  /**
   * 预览文件
   */
  const handlePreview = (file: FileItem): void => {
    if (file.url) {
      window.open(file.url, '_blank')
    }
  }

  /**
   * 下载文件
   */
  const handleDownload = (file: FileItem): void => {
    if (file.url) {
      const a = document.createElement('a')
      a.href = file.url
      a.download = file.name
      a.click()
    }
  }

  /**
   * 重命名
   */
  const handleRename = (file: FileItem): void => {
    renameForm.id = file.id
    renameForm.name = file.name
    renameDialogVisible.value = true
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
      await updatePmFileApi(String(renameForm.id), {
        name: renameForm.name
      })
      ElMessage.success('重命名成功')
      renameDialogVisible.value = false
      await loadFiles()
    } catch (error) {
      console.error('重命名失败:', error)
      ElMessage.error('重命名失败')
    } finally {
      renaming.value = false
    }
  }

  /**
   * 加载所有文件夹列表（用于移动选择）
   */
  const loadFolderList = async (): Promise<void> => {
    if (!projectData?.id) return
    try {
      const res = await listPmFileApi({
        'q[project_id_eq]': projectData.id,
        'q[kind_eq]': 0 // 只获取文件夹
      })
      folderList.value = (res as any).data || []
    } catch (error) {
      console.error('加载文件夹列表失败:', error)
    }
  }

  /**
   * 打开移动弹窗
   */
  const handleMove = async (file: FileItem): Promise<void> => {
    moveForm.id = file.id
    moveForm.name = file.name
    moveForm.targetParentId = file.parent_id || null
    await loadFolderList()
    moveDialogVisible.value = true
  }

  /**
   * 提交移动
   */
  const handleSubmitMove = async (): Promise<void> => {
    moving.value = true
    try {
      await updatePmFileApi(String(moveForm.id), {
        parent_id: moveForm.targetParentId
      })
      ElMessage.success('移动成功')
      moveDialogVisible.value = false
      await loadFiles()
    } catch (error) {
      console.error('移动失败:', error)
      ElMessage.error('移动失败')
    } finally {
      moving.value = false
    }
  }

  /**
   * 文件操作命令
   */
  const handleFileCommand = async (command: string, file: FileItem): Promise<void> => {
    switch (command) {
      case 'download':
        handleDownload(file)
        break
      case 'rename':
        handleRename(file)
        break
      case 'move':
        handleMove(file)
        break
      case 'delete':
        try {
          await ElMessageBox.confirm(`确定要删除"${file.name}"吗？`, '确认删除', {
            type: 'warning'
          })
          await deletePmFileApi(Number(file.id))
          ElMessage.success('删除成功')
          await loadFiles()
        } catch (error: any) {
          if (error !== 'cancel') {
            ElMessage.error('删除失败')
          }
        }
        break
    }
  }

  /**
   * 获取文件图标
   */
  const getFileIcon = (file: FileItem): string => {
    if (file.kind === 0) return 'ri:folder-fill'

    const ext = file.name.split('.').pop()?.toLowerCase()
    switch (ext) {
      case 'pdf':
        return 'ri:file-pdf-2-line'
      case 'doc':
      case 'docx':
        return 'ri:file-word-line'
      case 'xls':
      case 'xlsx':
        return 'ri:file-excel-line'
      case 'ppt':
      case 'pptx':
        return 'ri:file-ppt-line'
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'ri:image-line'
      case 'mp4':
      case 'avi':
      case 'mov':
        return 'ri:video-line'
      case 'mp3':
      case 'wav':
        return 'ri:music-line'
      case 'zip':
      case 'rar':
      case '7z':
        return 'ri:file-zip-line'
      case 'json':
        return 'ri:braces-line'
      case 'js':
      case 'ts':
      case 'vue':
      case 'jsx':
      case 'tsx':
        return 'ri:code-s-slash-line'
      default:
        return 'ri:file-line'
    }
  }

  /**
   * 获取文件图标样式类
   */
  const getFileIconClass = (file: FileItem): string => {
    if (file.kind === 0) return 'icon-folder'

    const ext = file.name.split('.').pop()?.toLowerCase()
    if (['pdf'].includes(ext || '')) return 'icon-pdf'
    if (['doc', 'docx'].includes(ext || '')) return 'icon-word'
    if (['xls', 'xlsx'].includes(ext || '')) return 'icon-excel'
    if (['ppt', 'pptx'].includes(ext || '')) return 'icon-ppt'
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext || '')) return 'icon-image'
    if (['json'].includes(ext || '')) return 'icon-json'
    return 'icon-default'
  }

  /**
   * 格式化文件大小
   */
  const formatFileSize = (bytes?: number): string => {
    if (!bytes) return '-'
    if (bytes < 1024) return bytes + ' B'
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
    if (bytes < 1024 * 1024 * 1024) return (bytes / 1024 / 1024).toFixed(1) + ' MB'
    return (bytes / 1024 / 1024 / 1024).toFixed(1) + ' GB'
  }

  /**
   * 格式化日期
   */
  const formatDate = (date?: string): string => {
    if (!date) return '-'
    const d = new Date(date)
    const now = new Date()
    const isToday = d.toDateString() === now.toDateString()
    if (isToday) return '今天'

    const year = d.getFullYear()
    const month = d.getMonth() + 1
    const day = d.getDate()
    return `${year}年${month}月${day}日`
  }

  onMounted(() => {
    loadFiles()
  })

  // 监听项目数据变化，确保刷新时能加载数据
  watch(
    () => projectData?.id,
    (newId) => {
      if (newId && fileList.value.length === 0) {
        loadFiles()
      }
    },
    { immediate: true }
  )
</script>

<style scoped lang="scss">
  @reference '@styles/core/tailwind.css';

  .files-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    overflow: hidden;
    background: #fff;
    border-radius: 8px;
  }

  .files-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .toolbar-left {
    display: flex;
    align-items: center;
  }

  .breadcrumb {
    display: flex;
    align-items: center;
    font-size: 14px;
  }

  .breadcrumb-item {
    color: var(--el-text-color-regular);
    cursor: pointer;

    &:hover {
      color: var(--el-color-primary);
    }

    &.active {
      font-weight: 500;
      color: var(--el-text-color-primary);
    }
  }

  .breadcrumb-separator {
    margin: 0 4px;
    color: var(--el-text-color-placeholder);
  }

  .toolbar-right {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .view-switch {
    display: flex;
    gap: 4px;
    align-items: center;
    padding: 4px;
    background: var(--el-fill-color-light);
    border-radius: 4px;

    .el-button {
      padding: 4px 8px;

      &.active {
        background: #fff;
        box-shadow: 0 1px 2px rgb(0 0 0 / 10%);
      }
    }
  }

  .files-list {
    flex: 1;
    overflow-y: auto;
  }

  .file-name-cell {
    display: flex;
    gap: 12px;
    align-items: center;
  }

  .file-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 18px;
    border-radius: 6px;

    &.icon-folder {
      color: #2196f3;
      background: #e3f2fd;
    }

    &.icon-pdf {
      color: #f44336;
      background: #ffebee;
    }

    &.icon-word {
      color: #1976d2;
      background: #e3f2fd;
    }

    &.icon-excel {
      color: #4caf50;
      background: #e8f5e9;
    }

    &.icon-ppt {
      color: #ff9800;
      background: #fff3e0;
    }

    &.icon-image {
      color: #9c27b0;
      background: #f3e5f5;
    }

    &.icon-json {
      color: #3f51b5;
      background: #e8eaf6;
    }

    &.icon-default {
      color: var(--el-text-color-secondary);
      background: var(--el-fill-color);
    }
  }

  .file-name {
    font-size: 14px;
    color: var(--el-text-color-primary);
    cursor: pointer;

    &:hover {
      color: var(--el-color-primary);
    }
  }

  .file-actions {
    display: flex;
    gap: 0;
    align-items: center;
    justify-content: flex-start;

    :deep(.el-button) {
      padding: 4px;
      margin: 0;
    }
  }

  :deep(.el-table__row) {
    .file-actions {
      opacity: 0;
      transition: opacity 0.2s;
    }

    &:hover .file-actions {
      opacity: 1;
    }
  }

  .files-grid {
    display: grid;
    flex: 1;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 16px;
    align-content: start;
    padding: 20px;
    overflow-y: auto;
  }

  .file-card {
    position: relative;
    padding: 16px;
    cursor: pointer;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    transition: all 0.2s;

    &:hover {
      border-color: var(--el-color-primary-light-5);
      box-shadow: 0 2px 8px rgb(0 0 0 / 8%);

      .card-actions {
        opacity: 1;
      }
    }
  }

  .card-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    margin: 0 auto 12px;
    font-size: 24px;
    border-radius: 8px;

    &.icon-folder {
      color: #2196f3;
      background: #e3f2fd;
    }

    &.icon-pdf {
      color: #f44336;
      background: #ffebee;
    }

    &.icon-word {
      color: #1976d2;
      background: #e3f2fd;
    }

    &.icon-excel {
      color: #4caf50;
      background: #e8f5e9;
    }

    &.icon-image {
      color: #9c27b0;
      background: #f3e5f5;
    }

    &.icon-json {
      color: #3f51b5;
      background: #e8eaf6;
    }

    &.icon-default {
      color: var(--el-text-color-secondary);
      background: var(--el-fill-color);
    }
  }

  .card-name {
    margin-bottom: 4px;
    overflow: hidden;
    font-size: 13px;
    color: var(--el-text-color-primary);
    text-align: center;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .card-meta {
    font-size: 12px;
    color: var(--el-text-color-secondary);
    text-align: center;
  }

  .card-actions {
    position: absolute;
    top: 8px;
    right: 8px;
    z-index: 10;
    opacity: 0;
    transition: opacity 0.2s;
  }

  .actions-trigger {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    cursor: pointer;
    background: rgb(255 255 255 / 90%);
    border-radius: 4px;

    &:hover {
      background: var(--el-fill-color);
    }
  }

  .move-dialog-content {
    .move-tip {
      margin-bottom: 12px;
      font-size: 14px;
      color: var(--el-text-color-regular);
    }

    .folder-tree {
      max-height: 300px;
      overflow-y: auto;
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 4px;
    }

    .folder-item {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      cursor: pointer;
      transition: background 0.2s;

      &:hover {
        background: var(--el-fill-color-light);
      }

      &.active {
        color: var(--el-color-primary);
        background: var(--el-color-primary-light-9);
      }

      &.disabled {
        cursor: not-allowed;
        opacity: 0.5;

        &:hover {
          background: transparent;
        }
      }

      .folder-icon {
        font-size: 18px;
        color: var(--el-color-warning);
      }
    }
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    grid-column: 1 / -1;
    align-items: center;
    justify-content: center;
    padding: 60px 0;
    color: var(--el-text-color-secondary);
  }

  .empty-icon {
    margin-bottom: 12px;
    font-size: 48px;
    color: var(--el-text-color-placeholder);
  }
</style>
