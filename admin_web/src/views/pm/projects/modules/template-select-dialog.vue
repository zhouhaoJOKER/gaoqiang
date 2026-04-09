<!-- 项目模板选择弹窗 -->
<template>
  <ElDialog
    title="选择项目模板"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="800px"
    align-center
    class="template-select-dialog"
  >
    <div class="template-select-content">
      <!-- 搜索栏 -->
      <div class="mb-4">
        <ElInput
          v-model="searchKeyword"
          placeholder="搜索模板名称或描述"
          clearable
          @input="handleSearch"
        >
          <template #prefix>
            <ArtSvgIcon icon="ri:search-line" />
          </template>
        </ElInput>
      </div>

      <!-- 模板列表 -->
      <div v-if="loading" class="flex items-center justify-center h-64">
        <ElIcon class="is-loading">
          <ArtSvgIcon icon="ri:loader-4-line" class="text-2xl text-primary-500" />
        </ElIcon>
      </div>

      <div
        v-else-if="filteredTemplateList.length"
        class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3"
      >
        <ElCard
          v-for="item in filteredTemplateList"
          :key="item.id"
          class="template-card cursor-pointer transition-all duration-150 hover:shadow-md"
          :class="{ selected: selectedTemplateId === item.id }"
          shadow="never"
          @click="handleSelectTemplate(item)"
        >
          <!-- 模板 Logo 图片 -->
          <div v-if="item.logo" class="w-full h-24 mb-2 rounded-lg overflow-hidden bg-g-100">
            <img
              :src="getImageUrl(item.logo)"
              :alt="item.name"
              class="w-full h-full object-cover"
              @error="handleImageError"
            />
          </div>
          <!-- 无 Logo 时的占位符 -->
          <div v-else class="w-full h-24 mb-2 rounded-lg bg-g-100 flex items-center justify-center">
            <ArtSvgIcon icon="ri:image-line" class="text-2xl text-g-400" />
          </div>
          <!-- 模板信息 -->
          <div class="px-2 pb-2">
            <div class="text-sm font-medium text-g-900 truncate mb-1">
              {{ item.name }}
            </div>
            <div v-if="item.description" class="text-xs text-g-500 line-clamp-2">
              {{ item.description }}
            </div>
            <div v-else class="text-xs text-g-400">暂无描述</div>
          </div>
        </ElCard>
      </div>

      <!-- 空状态 -->
      <div v-else class="flex items-center justify-center h-64 text-sm text-g-400">
        <div class="text-center">
          <ArtSvgIcon icon="ri:file-list-3-line" class="text-4xl mb-2 text-g-300" />
          <div>{{ searchKeyword ? '未找到匹配的模板' : '暂无项目模板' }}</div>
        </div>
      </div>

      <!-- 跳过模板选项 -->
      <div class="mt-4 text-center">
        <ElButton text @click="handleSkipTemplate">
          <ArtSvgIcon icon="ri:skip-forward-line" class="mr-1" />
          不使用模板，直接创建
        </ElButton>
      </div>
    </div>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { listPmProjectTemplateApi } from '@/api/pm/template'

  interface TemplateItem {
    id?: string | number
    name?: string
    description?: string
    logo?: string
    [key: string]: any
  }

  interface Props {
    visible: boolean
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'select', template: TemplateItem): void
    (e: 'skip'): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const loading = ref(false)
  const templateList = ref<TemplateItem[]>([])
  const searchKeyword = ref('')
  const selectedTemplateId = ref<string | number | undefined>(undefined)

  /**
   * 获取图片 URL
   */
  const getImageUrl = (logo: string | undefined): string => {
    if (!logo) return ''
    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return logo
    }
    return logo.startsWith('/') ? logo : `/${logo}`
  }

  /**
   * 处理图片加载错误
   */
  const handleImageError = (event: Event): void => {
    const img = event.target as HTMLImageElement
    img.style.display = 'none'
  }

  /**
   * 过滤后的模板列表
   */
  const filteredTemplateList = computed(() => {
    if (!searchKeyword.value.trim()) {
      return templateList.value
    }
    const keyword = searchKeyword.value.toLowerCase().trim()
    return templateList.value.filter((item) => {
      const name = (item.name || '').toLowerCase()
      const description = (item.description || '').toLowerCase()
      return name.includes(keyword) || description.includes(keyword)
    })
  })

  /**
   * 获取模板列表
   */
  const getTemplateList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listPmProjectTemplateApi({
        current: 1,
        size: 100 // 获取所有模板用于选择
      })
      const data = (res as any).data || {}
      if (Array.isArray(data)) {
        templateList.value = data
      } else if (data.list || data.data || data.records) {
        templateList.value = data.list || data.data || data.records || []
      } else {
        templateList.value = []
      }
    } catch (error) {
      console.error('获取模板列表失败:', error)
      templateList.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * 处理搜索
   */
  const handleSearch = (): void => {
    // 搜索逻辑已在 computed 中处理
  }

  /**
   * 选择模板
   */
  const handleSelectTemplate = (template: TemplateItem): void => {
    selectedTemplateId.value = template.id
    emit('select', template)
    handleCancel()
  }

  /**
   * 跳过模板选择
   */
  const handleSkipTemplate = (): void => {
    emit('skip')
    handleCancel()
  }

  /**
   * 取消操作
   */
  const handleCancel = (): void => {
    emit('update:visible', false)
    searchKeyword.value = ''
    selectedTemplateId.value = undefined
  }

  /**
   * 监听弹窗显示状态
   */
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        getTemplateList()
      }
    }
  )

  onMounted(() => {
    if (props.visible) {
      getTemplateList()
    }
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .template-select-content {
    @apply min-h-[400px];
  }

  .template-card {
    @apply transition-all;
  }

  .template-card:hover {
    @apply shadow-md;

    border-color: var(--el-color-primary) !important;
    border-width: 2px;
  }

  .template-card.selected {
    border-color: var(--el-color-primary) !important;

    @apply shadow-md;

    border-width: 2px;
  }
</style>
