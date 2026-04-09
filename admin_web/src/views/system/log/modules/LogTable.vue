<!-- 日志表格组件 -->
<!-- art-full-height 自动计算出页面剩余高度 -->
<!-- art-table-card 一个符合系统样式的 class，同时自动撑满剩余高度 -->
<!-- 更多 useTable 使用示例请移步至 功能示例 下面的高级表格示例或者查看官方文档 -->
<!-- useTable 文档：https://www.artd.pro/docs/zh/guide/hooks/use-table.html -->
<template>
  <ElCard class="art-table-card" :class="{ 'log-table--embedded': embedded }" shadow="never">
    <!-- 表格头部 -->
    <ArtTableHeader v-model:columns="columnChecks" :loading="loading" @refresh="refreshData">
    </ArtTableHeader>

    <!-- 表格 -->
    <ArtTable
      ref="proTable"
      :loading="loading"
      :data="data as Record<string, any>[]"
      :columns="columns"
      :pagination="pagination"
      @selection-change="handleSelectionChange"
      @pagination:size-change="handleSizeChange"
      @pagination:current-change="handleCurrentChange"
    >
    </ArtTable>
  </ElCard>
</template>

<script setup lang="ts">
  defineOptions({ name: 'LogTable' })
  import { ref, h, watch } from 'vue'
  import { useTable } from '@/hooks/core/useTable'
  import { listLogApi } from '@/api/system-manage'
  import { ElTag, ElCard } from 'element-plus'
  import ArtTableHeader from '@/components/core/tables/art-table-header/index.vue'
  import ArtTable from '@/components/core/tables/art-table/index.vue'

  // 定义props
  const props = defineProps({
    category: {
      type: String,
      required: true
    },
    /** 嵌入页签等场景：弱化卡片边框与背景 */
    embedded: {
      type: Boolean,
      default: false
    },
    /** 按关联记录筛选（与 recordType 同时传入时生效） */
    recordId: {
      type: [String, Number],
      default: undefined
    },
    recordType: {
      type: String,
      default: undefined
    }
  })

  function buildLogQuery(p: {
    category: string
    recordId?: string | number | null
    recordType?: string | null
  }) {
    const q: Record<string, unknown> = {
      category_eq: p.category
    }
    if (p.recordId != null && p.recordId !== '' && p.recordType) {
      q.record_id_eq = p.recordId
      q.record_type_eq = p.recordType
    }
    return q
  }

  // 表格实例ref
  const proTable = ref<any>(null)

  // 格式化日期时间
  const formatDateTime = (dateTime: string) => {
    if (!dateTime) return ''
    const date = new Date(dateTime)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  }

  // 使用useTable钩子
  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    handleSizeChange,
    handleCurrentChange,
    refreshData,
    searchParams
  } = useTable({
    core: {
      apiFn: listLogApi,
      apiParams: {
        q: buildLogQuery(props),
        current: 1,
        size: 20
      },
      columnsFactory: () => [
        { type: 'index', width: 50, label: 'ID' },
        {
          prop: 'user_name',
          label: '用户名',
          width: 90
        },
        {
          prop: 'ip',
          label: 'IP地址',
          width: 100
        },
        {
          prop: 'describe',
          label: '描述',
          minWidth: 240,
          showOverflowTooltip: true
        },
        {
          prop: 'result',
          label: '结果',
          width: 80,
          formatter: (row: unknown) => {
            const logRow = row as Record<string, any>
            return h(
              ElTag,
              {
                type: logRow.result === true ? 'success' : 'danger'
              },
              logRow.result === true ? '成功' : '失败'
            )
          }
        },
        {
          prop: 'event',
          label: '事件',
          minWidth: 150
        },
        // {
        //   prop: 'category',
        //   label: '分类',
        //   width: 100,
        //   formatter: (row) => {
        //     return h(ElTag, {
        //       type: getCategoryType(row.category)
        //     }, getCategoryLabel(row.category))
        //   }
        // },
        {
          prop: 'modules',
          label: '模块',
          width: 120
        },
        {
          prop: 'created_time',
          label: '创建时间',
          width: 180,
          sortable: true,
          formatter: (row: unknown) => {
            const logRow = row as Record<string, any>
            return formatDateTime(logRow.created_time)
          }
        }
      ]
    }
  })

  // 监听筛选条件变化，重新加载数据
  watch(
    () => [props.category, props.recordId, props.recordType] as const,
    () => {
      const q = buildLogQuery(props)
      searchParams.q = { ...q }
      handleCurrentChange(1)
    },
    { immediate: true }
  )

  // 处理表格行选择变化
  const handleSelectionChange = (selection: any[]): void => {
    console.log('选中行数据:', selection)
  }
</script>

<style scoped>
  .log-page {
    width: 100%;
  }

  .log-table--embedded {
    background: transparent;
    border: none;
    box-shadow: none;

    :deep(.el-card__body) {
      padding: 0;
    }
  }
</style>
