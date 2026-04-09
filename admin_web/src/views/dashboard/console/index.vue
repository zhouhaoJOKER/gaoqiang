<!-- 瓶子生产运营看板：生产订单 · 各阶段 / 交期预警 / 逾期与产线异常 -->
<template>
  <div class="contract-board" :class="{ 'contract-board--fullscreen': isFullscreen }">
    <!-- 顶部栏 -->
    <header class="board-header">
      <div class="board-header-left">
        <h1 class="board-title">企业生产运营看板</h1>
        <!-- prettier-ignore -->
        <span class="board-subtitle">堆码 · 桶盖子 · 聚乙烯 PE · 多层高阻 · 隔聚酯 PET · 瓶子 · 子母系列 · 订单与产线协同</span>
      </div>
      <div class="board-header-right">
        <span class="board-time">{{ currentTime }}</span>
        <ElButton type="primary" link class="board-btn" @click="refreshData">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
        <ElButton type="primary" link class="board-btn" @click="toggleFullscreen">
          <ArtSvgIcon
            :icon="isFullscreen ? 'ri:fullscreen-exit-line' : 'ri:fullscreen-line'"
            class="mr-1"
          />
          {{ isFullscreen ? '退出全屏' : '全屏' }}
        </ElButton>
      </div>
    </header>

    <!-- 产线概要：七大品类订单量 + 排产与质检 -->
    <section class="board-agro">
      <div v-for="row in productStripStats.categories" :key="row.key" class="agro-item">
        <span class="agro-label">{{ row.label }}</span>
        <span class="agro-value">{{ row.count }} 单</span>
      </div>
      <div class="agro-item agro-item--meta">
        <span class="agro-label">当前排产重点</span>
        <span class="agro-value">{{ productStripStats.peakLineLabel }}</span>
      </div>
      <div class="agro-item agro-item--meta">
        <span class="agro-label">本月质检批次</span>
        <span class="agro-value">{{ productStripStats.qcBatches }} 批</span>
      </div>
    </section>

    <!-- KPI 卡片 -->
    <section class="board-kpi">
      <div class="kpi-card">
        <div class="kpi-value">{{ kpi.total }}</div>
        <div class="kpi-label">生产订单总数</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-value">{{ kpi.inProgress }}</div>
        <div class="kpi-label">在制 / 执行中</div>
      </div>
      <div class="kpi-card kpi-card--warn">
        <div class="kpi-value">{{ kpi.approaching }}</div>
        <div class="kpi-label">7 天内应交期</div>
      </div>
      <div class="kpi-card kpi-card--danger">
        <div class="kpi-value">{{ kpi.overdue }}</div>
        <div class="kpi-label">已逾期未交货</div>
      </div>
      <div class="kpi-card kpi-card--alert">
        <div class="kpi-value">{{ kpi.issue }}</div>
        <div class="kpi-label">产线异常</div>
      </div>
    </section>

    <!-- 产线异常 + 交期预警 | 今日在制 右侧 -->
    <section class="board-issue">
      <div class="board-panel board-panel--issue-combined">
        <div class="panel-title panel-title--alert panel-title--compact">
          产线异常与工序卡点
          <span class="panel-desc">订单交期风险与当前停滞工序</span>
        </div>
        <div class="panel-content panel-content--scroll panel-content--issue-short">
          <ElTable :data="issueList" size="small" class="board-table board-table--no-stripe">
            <ElTableColumn prop="code" label="订单号" width="108" />
            <ElTableColumn prop="product_type_label" label="品类" width="96" align="center" />
            <ElTableColumn prop="client_name" label="客户" min-width="88" show-overflow-tooltip />
            <ElTableColumn prop="deliver_at" label="约定交期" width="96" align="center" />
            <ElTableColumn
              prop="issue_reason"
              label="异常原因"
              min-width="120"
              show-overflow-tooltip
            />
            <ElTableColumn prop="stuck_step" label="停滞工序" width="96" align="center">
              <template #default="{ row }">
                <ElTag type="warning" size="small">{{ row.stuck_step }}</ElTag>
              </template>
            </ElTableColumn>
            <ElTableColumn prop="stuck_days" label="停留" width="56" align="center" />
          </ElTable>
        </div>
        <div class="issue-combined-bottom">
          <div class="issue-combined-table">
            <div class="panel-title panel-title--warn panel-title--compact">
              7 天内到期订单
              <span class="panel-badge">{{ approachingList.length }}</span>
            </div>
            <div class="panel-content panel-content--scroll panel-content--table-tall">
              <ElTable
                :data="approachingList"
                size="small"
                class="board-table board-table--no-stripe"
              >
                <ElTableColumn prop="code" label="订单号" width="108" />
                <ElTableColumn prop="product_type_label" label="品类" width="96" align="center" />
                <ElTableColumn
                  prop="client_name"
                  label="客户"
                  min-width="88"
                  show-overflow-tooltip
                />
                <ElTableColumn prop="deliver_at" label="约定交期" width="96" align="center" />
                <ElTableColumn prop="stage_label" label="阶段" width="72" />
                <ElTableColumn prop="days_left" label="剩余" width="64" align="center">
                  <template #default="{ row }">
                    <span class="text-warn">{{ row.days_left }}天</span>
                  </template>
                </ElTableColumn>
              </ElTable>
            </div>
          </div>
          <div class="issue-combined-table">
            <div class="panel-title panel-title--danger panel-title--compact">
              已到期未交货
              <span class="panel-badge">{{ overdueList.length }}</span>
            </div>
            <div class="panel-content panel-content--scroll panel-content--table-tall">
              <ElTable :data="overdueList" size="small" class="board-table board-table--no-stripe">
                <ElTableColumn prop="code" label="订单号" width="108" />
                <ElTableColumn prop="product_type_label" label="品类" width="96" align="center" />
                <ElTableColumn
                  prop="client_name"
                  label="客户"
                  min-width="88"
                  show-overflow-tooltip
                />
                <ElTableColumn prop="deliver_at" label="应交期" width="96" align="center" />
                <ElTableColumn prop="stage_label" label="阶段" width="72" />
                <ElTableColumn prop="overdue_days" label="逾期" width="64" align="center">
                  <template #default="{ row }">
                    <span class="text-danger">{{ row.overdue_days }}天</span>
                  </template>
                </ElTableColumn>
              </ElTable>
            </div>
          </div>
        </div>
        <div class="issue-combined-chart">
          <div class="issue-combined-chart__col">
            <div class="issue-combined-chart__title">订单阶段分布</div>
            <div class="issue-combined-chart__wrap">
              <ArtRingChart
                height="100%"
                :data="stageChartData"
                :radius="['38%', '58%']"
                :colors="chartRingColors"
                :show-legend="true"
                legend-position="right"
                dark-background
              />
            </div>
          </div>
          <div class="issue-combined-chart__col">
            <div class="issue-combined-chart__title">近四周周订单量</div>
            <div class="issue-combined-chart__wrap">
              <ArtBarChart
                height="100%"
                :data="weeklyContractCountData"
                :x-axis-data="weeklyContractCountLabels"
                :show-legend="false"
                :colors="chartBarColors"
                class="board-bar-chart"
              />
            </div>
          </div>
        </div>
      </div>
      <div class="board-panel board-panel--producing">
        <div class="panel-title panel-title--accent">
          今日产线在制订单
          <span class="panel-badge">{{ producingList.length }}</span>
        </div>
        <div class="panel-content panel-content--scroll producing-scroll-wrap">
          <div class="producing-scroll-inner">
            <template v-for="(_, copyIndex) in 2" :key="copyIndex">
              <div
                v-for="item in producingList"
                :key="`${copyIndex}-${item.code}`"
                class="producing-item"
              >
                <div class="producing-item__head">
                  <span class="producing-item__code">{{ item.code }}</span>
                  <span class="producing-item__type">{{ item.product_type_label }}</span>
                  <span class="producing-item__deliver">交期 {{ item.deliver_at }}</span>
                </div>
                <div class="producing-item__client">{{ item.client_name }}</div>
                <div class="producing-item__progress">
                  <div class="producing-item__progress-bar">
                    <div
                      class="producing-item__progress-fill"
                      :style="{ width: item.completion_pct + '%' }"
                    />
                  </div>
                  <span class="producing-item__progress-pct">{{ item.completion_pct }}%</span>
                </div>
                <div class="producing-item__days">
                  <template v-if="item.completion_pct >= 100">
                    <span class="text-success">已下产线</span>
                  </template>
                  <template v-else>
                    <span>已生产 {{ item.days_done }} 天</span>
                    <span class="producing-item__remain"
                      >预估剩余 {{ item.days_estimated_remain }} 天</span
                    >
                  </template>
                </div>
              </div>
            </template>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, onUnmounted } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtRingChart from '@/components/core/charts/art-ring-chart/index.vue'
  import ArtBarChart from '@/components/core/charts/art-bar-chart/index.vue'
  import { ElTable, ElTableColumn, ElButton, ElTag } from 'element-plus'
  import dayjs from 'dayjs'

  defineOptions({ name: 'DashboardBottleProductionBoard' })

  const STAGES = [
    { key: 'draft', label: '草稿' },
    { key: 'approving', label: '审单中' },
    { key: 'signed', label: '已排产' },
    { key: 'producing', label: '制瓶中' },
    { key: 'pending_ship', label: '待出货' },
    { key: 'shipped', label: '已发货' },
    { key: 'delivered', label: '已签收' }
  ] as const

  type StageKey = (typeof STAGES)[number]['key']

  /** 主要产品品类（与业务一致） */
  const PRODUCT_CATEGORIES = [
    { key: 'stacking', label: '堆码' },
    { key: 'bucket_lid', label: '桶盖子' },
    { key: 'pe', label: '聚乙烯 PE' },
    { key: 'multilayer_barrier', label: '多层高阻' },
    { key: 'barrier_pet', label: '隔聚酯 PET' },
    { key: 'bottle', label: '瓶子' },
    { key: 'nested_series', label: '子母系列' }
  ] as const

  type ProductType = (typeof PRODUCT_CATEGORIES)[number]['key']

  const PRODUCT_TYPE_LABEL: Record<ProductType, string> = {
    stacking: '堆码',
    bucket_lid: '桶盖子',
    pe: '聚乙烯 PE',
    multilayer_barrier: '多层高阻',
    barrier_pet: '隔聚酯 PET',
    bottle: '瓶子',
    nested_series: '子母系列'
  }

  const PRODUCT_TYPE_KEYS: ProductType[] = PRODUCT_CATEGORIES.map((c) => c.key)

  /** Mock：主要客户（按提供名单的频次加权抽样，金陵 / 瑞辰植保 / 南通功成略多） */
  const MOCK_CLIENT_POOL_WEIGHTED = [
    '南通功成',
    '南通功成',
    '金陵',
    '金陵',
    '金陵',
    '金陵',
    '济南乐丰',
    '江苏优科',
    '江苏云帆',
    '瑞辰植保',
    '瑞辰植保'
  ] as const

  interface ContractItem {
    id: number
    code: string
    product_type: ProductType
    product_type_label: string
    client_name: string
    deliver_at: string
    stage: StageKey
    stage_label: string
    days_left?: number
    overdue_days?: number
    issue_reason?: string
    stuck_step?: string
    stuck_days?: number
  }

  const isFullscreen = ref(false)
  const currentTime = ref('')
  let timeTimer: ReturnType<typeof setInterval> | null = null

  const updateTime = () => {
    currentTime.value = dayjs().format('YYYY-MM-DD HH:mm:ss')
  }

  // Mock：生产订单列表（含阶段、交期、异常与工序卡点）
  const allContracts = ref<ContractItem[]>([])

  function buildMockContracts() {
    const clients = MOCK_CLIENT_POOL_WEIGHTED
    const productTypes = PRODUCT_TYPE_KEYS
    const list: ContractItem[] = []
    const today = dayjs().startOf('day')
    let id = 1
    STAGES.forEach((s, stageIndex) => {
      const count = stageIndex <= 1 ? 3 : stageIndex === 2 ? 8 : stageIndex < 6 ? 12 : 15
      for (let i = 0; i < count; i++) {
        const productType = productTypes[Math.floor(Math.random() * productTypes.length)]
        let deliverAt = today
        if (stageIndex <= 1) deliverAt = today.add(30 + Math.floor(Math.random() * 60), 'day')
        else if (stageIndex === 2) deliverAt = today.add(5 + Math.floor(Math.random() * 25), 'day')
        else if (stageIndex <= 4) deliverAt = today.add(-15 + Math.floor(Math.random() * 25), 'day')
        else deliverAt = today.add(-40 - Math.floor(Math.random() * 20), 'day')
        const daysDiff = deliverAt.diff(today, 'day')
        const item: ContractItem = {
          id: id++,
          code: `PO-2026${String(1000 + id).slice(-3)}`,
          product_type: productType,
          product_type_label: PRODUCT_TYPE_LABEL[productType],
          client_name: clients[Math.floor(Math.random() * clients.length)],
          deliver_at: deliverAt.format('YYYY-MM-DD'),
          stage: s.key,
          stage_label: s.label,
          days_left: daysDiff >= 0 ? daysDiff : undefined,
          overdue_days: daysDiff < 0 ? -daysDiff : undefined,
          issue_reason: undefined,
          stuck_step: undefined,
          stuck_days: undefined
        }
        list.push(item)
      }
    })
    // 强制几条“即将到期”（7 天内）和“已逾期”
    const signedOrLater = list.filter((c) =>
      ['signed', 'producing', 'pending_ship'].includes(c.stage)
    )
    signedOrLater.slice(0, 4).forEach((c, i) => {
      const d = today.add(i - 1, 'day')
      c.deliver_at = d.format('YYYY-MM-DD')
      const diff = d.diff(today, 'day')
      c.days_left = diff >= 0 ? diff : undefined
      c.overdue_days = diff < 0 ? -diff : undefined
    })
    signedOrLater.slice(4, 8).forEach((c, i) => {
      const d = today.add(-3 - i, 'day')
      c.deliver_at = d.format('YYYY-MM-DD')
      c.days_left = undefined
      c.overdue_days = today.diff(d, 'day')
    })
    // 产线异常：瓶类生产常见原因与停滞工序
    const issueReasons = [
      '堆码托盘不足',
      '桶盖模具更换',
      'PE 粒子批次待检',
      '高阻隔共挤调机',
      '隔聚酯瓶胚延期',
      '瓶型换产',
      '子母件配套不齐'
    ]
    const stuckSteps = ['注塑', '吹塑', '共挤', '品检', '堆码入库']
    list
      .filter((c) => c.stage === 'producing' || c.stage === 'pending_ship')
      .slice(0, 6)
      .forEach((c, i) => {
        if (i < 4) {
          c.issue_reason = issueReasons[i % issueReasons.length]
          c.stuck_step = stuckSteps[i % stuckSteps.length]
          c.stuck_days = 2 + Math.floor(Math.random() * 5)
        }
      })
    allContracts.value = list
  }

  const stageCounts = computed(() => {
    const map: Record<string, number> = {}
    STAGES.forEach((s) => {
      map[s.label] = allContracts.value.filter((c) => c.stage === s.key).length
    })
    return map
  })

  const stageChartData = computed(() =>
    STAGES.map((s) => ({ name: s.label, value: stageCounts.value[s.label] || 0 })).filter(
      (d) => d.value > 0
    )
  )

  // 近四周周订单量（mock）
  const weeklyContractCountLabels = computed(() => {
    const labels: string[] = []
    for (let i = 3; i >= 0; i--) {
      labels.push(`第 ${4 - i} 周`)
    }
    return labels
  })
  const weeklyContractCountData = computed(() => {
    const base = allContracts.value.length
    return [base * 0.18 + 2, base * 0.22 + 1, base * 0.28 + 3, base * 0.32 + 2].map((v) =>
      Math.round(v)
    )
  })

  // 图表配色（与看板主题一致）
  const chartRingColors = [
    '#5eb3f6',
    '#67c23a',
    '#e6a23c',
    '#909399',
    '#f56c6c',
    '#9b59b6',
    '#00d4aa'
  ]
  const chartBarColors = ['#5eb3f6', '#7dd3fc', '#38bdf8', '#0ea5e9']

  const kpi = computed(() => ({
    total: allContracts.value.length,
    inProgress: allContracts.value.filter((c) =>
      ['approving', 'signed', 'producing', 'pending_ship', 'shipped'].includes(c.stage)
    ).length,
    approaching: approachingList.value.length,
    overdue: overdueList.value.length,
    issue: issueList.value.length
  }))

  const approachingList = computed(() =>
    allContracts.value
      .filter(
        (c) =>
          c.deliver_at &&
          c.days_left != null &&
          c.days_left >= 0 &&
          c.days_left <= 7 &&
          !['delivered'].includes(c.stage)
      )
      .sort((a, b) => (a.days_left ?? 0) - (b.days_left ?? 0))
      .slice(0, 20)
  )

  const overdueList = computed(() =>
    allContracts.value
      .filter(
        (c) =>
          c.deliver_at &&
          c.overdue_days != null &&
          c.overdue_days > 0 &&
          !['delivered'].includes(c.stage)
      )
      .sort((a, b) => (b.overdue_days ?? 0) - (a.overdue_days ?? 0))
      .slice(0, 20)
  )

  const issueList = computed(() =>
    allContracts.value.filter((c) => c.issue_reason && c.stuck_step).slice(0, 15)
  )

  // 今日产线在制订单（示例数据：完成率、已生产天数、预估剩余天数）
  interface ProducingOrderItem {
    code: string
    product_type_label: string
    client_name: string
    deliver_at: string
    completion_pct: number
    days_done: number
    days_estimated_remain: number
  }
  const producingList: ProducingOrderItem[] = [
    {
      code: 'PO-2026012',
      product_type_label: '瓶子',
      client_name: '南通功成',
      deliver_at: '2026-04-02',
      completion_pct: 100,
      days_done: 12,
      days_estimated_remain: 0
    },
    {
      code: 'PO-2026015',
      product_type_label: '隔聚酯 PET',
      client_name: '金陵',
      deliver_at: '2026-04-05',
      completion_pct: 68,
      days_done: 8,
      days_estimated_remain: 4
    },
    {
      code: 'PO-2026018',
      product_type_label: '聚乙烯 PE',
      client_name: '济南乐丰',
      deliver_at: '2026-04-08',
      completion_pct: 45,
      days_done: 5,
      days_estimated_remain: 6
    },
    {
      code: 'PO-2026021',
      product_type_label: '桶盖子',
      client_name: '江苏优科',
      deliver_at: '2026-04-10',
      completion_pct: 22,
      days_done: 3,
      days_estimated_remain: 11
    },
    {
      code: 'PO-2026024',
      product_type_label: '多层高阻',
      client_name: '江苏云帆',
      deliver_at: '2026-04-12',
      completion_pct: 90,
      days_done: 9,
      days_estimated_remain: 1
    },
    {
      code: 'PO-2026027',
      product_type_label: '子母系列',
      client_name: '瑞辰植保',
      deliver_at: '2026-04-15',
      completion_pct: 55,
      days_done: 6,
      days_estimated_remain: 5
    },
    {
      code: 'PO-2026030',
      product_type_label: '堆码',
      client_name: '金陵',
      deliver_at: '2026-04-18',
      completion_pct: 33,
      days_done: 4,
      days_estimated_remain: 8
    },
    {
      code: 'PO-2026033',
      product_type_label: '瓶子',
      client_name: '南通功成',
      deliver_at: '2026-04-22',
      completion_pct: 78,
      days_done: 7,
      days_estimated_remain: 2
    }
  ]

  /** 顶部信息条：七大品类在制/未结订单量、排产主题、本月质检批次数 */
  const productStripStats = computed(() => {
    const list = allContracts.value.filter((c) => !['draft', 'delivered'].includes(c.stage))
    const categories = PRODUCT_CATEGORIES.map((c) => ({
      key: c.key,
      label: c.label,
      count: list.filter((x) => x.product_type === c.key).length
    }))
    const month = dayjs().month()
    const peakLineLabel =
      month >= 2 && month <= 5
        ? 'PE / 瓶子线保供'
        : month >= 6 && month <= 8
          ? '高阻隔与隔聚酯集中排产'
          : month >= 9 && month <= 11
            ? '桶盖与子母件备货'
            : '堆码与常规品出货'
    const qcBatches = 26 + (dayjs().date() % 14)
    return {
      categories,
      peakLineLabel,
      qcBatches
    }
  })

  const refreshData = () => {
    buildMockContracts()
  }

  const toggleFullscreen = () => {
    isFullscreen.value = !isFullscreen.value
    if (isFullscreen.value) {
      document.documentElement.classList.add('contract-board-fullscreen')
    } else {
      document.documentElement.classList.remove('contract-board-fullscreen')
    }
  }

  onMounted(() => {
    buildMockContracts()
    updateTime()
    timeTimer = setInterval(updateTime, 1000)
  })

  onUnmounted(() => {
    if (timeTimer) clearInterval(timeTimer)
    document.documentElement.classList.remove('contract-board-fullscreen')
  })
</script>

<style scoped lang="scss">
  .contract-board {
    --board-bg: #1a2332;
    --board-panel-bg: rgb(255 255 255 / 7%);
    --board-border: rgb(255 255 255 / 12%);
    --board-text: #f0f4f8;
    --board-text-muted: #b8c5d6;
    --board-accent: #5eb3f6;
    --board-warn: #e6a23c;
    --board-danger: #f56c6c;
    --board-success: #67c23a;

    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    height: 100vh;
    min-height: 100%;
    padding: 10px 12px;
    overflow: hidden;
    color: var(--board-text);
    background: var(--board-bg);
  }

  .contract-board--fullscreen {
    position: fixed;
    inset: 0;
    z-index: 2300;
    height: 100vh;
    overflow: hidden;
  }

  .board-header {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 8px;
    margin-bottom: 8px;
    border-bottom: 1px solid var(--board-border);
  }

  .board-title {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
    color: var(--board-text);
    letter-spacing: 0.02em;
  }

  .board-subtitle {
    display: block;
    margin-top: 2px;
    font-size: 12px;
    color: var(--board-text-muted);
  }

  .board-header-right {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .board-time {
    font-size: 13px;
    font-variant-numeric: tabular-nums;
    color: var(--board-text-muted);
  }

  .board-btn {
    color: var(--board-text-muted) !important;

    &:hover {
      color: var(--board-accent) !important;
    }
  }

  .board-agro {
    display: flex;
    flex-shrink: 0;
    flex-wrap: wrap;
    gap: 12px 16px;
    padding: 8px 12px;
    margin-bottom: 8px;
    background: var(--board-panel-bg);
    border: 1px solid var(--board-border);
    border-radius: 6px;
  }

  .agro-item {
    display: flex;
    gap: 6px;
    align-items: center;
    font-size: 12px;
  }

  .agro-item--meta {
    padding-left: 8px;
    margin-left: 4px;
    border-left: 1px solid var(--board-border);
  }

  .agro-label {
    color: var(--board-text-muted);
  }

  .agro-value {
    font-weight: 600;
    color: var(--board-text);
  }

  .board-kpi {
    display: grid;
    flex-shrink: 0;
    grid-template-columns: repeat(5, 1fr);
    gap: 8px;
    margin-bottom: 8px;
  }

  .kpi-card {
    padding: 10px 8px;
    text-align: center;
    background: var(--board-panel-bg);
    border: 1px solid var(--board-border);
    border-radius: 6px;
  }

  .kpi-value {
    font-size: 22px;
    font-weight: 700;
    font-variant-numeric: tabular-nums;
    color: var(--board-accent);
  }

  .kpi-label {
    margin-top: 2px;
    font-size: 11px;
    color: var(--board-text-muted);
  }

  .kpi-card--warn .kpi-value {
    color: var(--board-warn);
  }

  .kpi-card--danger .kpi-value {
    color: var(--board-danger);
  }

  .kpi-card--alert .kpi-value {
    color: var(--board-warn);
  }

  .board-panel {
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background: var(--board-panel-bg);
    border: 1px solid var(--board-border);
    border-radius: 6px;
  }

  .panel-content--chart {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 0;
    padding: 8px;
  }

  .panel-content--chart > * {
    flex: 1;
    min-height: 0;
  }

  .board-panel--table {
    min-height: 0;
  }

  /* 7天内 / 已到交付未交 两表取消斑马纹 */
  .board-table--no-stripe :deep(.el-table__row--striped),
  .board-table--no-stripe :deep(tr.el-table__row.striped) {
    background: transparent !important;
  }

  .board-table--no-stripe :deep(.el-table__body tr:hover > td) {
    background: var(--el-table-row-hover-bg-color) !important;
  }

  .panel-title {
    display: flex;
    align-items: center;
    padding: 8px 10px;
    font-size: 13px;
    font-weight: 600;
    color: var(--board-text);
    border-bottom: 1px solid var(--board-border);
  }

  .panel-title--warn {
    color: var(--board-warn);
  }

  .panel-title--danger {
    color: var(--board-danger);
  }

  .panel-title--alert {
    color: var(--board-warn);
  }

  .panel-badge {
    padding: 2px 6px;
    margin-left: 6px;
    font-size: 11px;
    color: var(--board-text);
    background: rgb(255 255 255 / 15%);
    border-radius: 8px;
  }

  .panel-desc {
    margin-left: 6px;
    font-size: 11px;
    font-weight: 400;
    color: var(--board-text-muted);
  }

  .panel-title--sub {
    padding-top: 6px;
    margin-top: 0;
    font-size: 12px;
    font-weight: 500;
    color: var(--board-text-muted);
    border-top: 1px solid var(--board-border);
  }

  .board-issue {
    display: grid;
    flex: 1;
    grid-template-columns: 1fr 380px;
    gap: 8px;
    align-items: stretch;
    min-height: 0;
    margin-bottom: 8px;
    overflow: hidden;
  }

  .board-panel--issue-combined {
    display: flex;
    flex-direction: column;
    min-height: 0;
  }

  .panel-title--compact {
    padding: 4px 8px;
    font-size: 12px;
  }

  /* 交付异常：固定高度显示 5 行（small 表头约 40px + 5 行约 32px/行） */
  .panel-content--issue-short {
    height: 216px;
    min-height: 216px;
    max-height: 216px;
    padding: 4px 8px;
    overflow-y: auto;
  }

  /* 下方两表：固定高度，数据多时上下滚动 */
  .panel-content--table-tall {
    flex: none;
    height: 200px;
    min-height: 200px;
    overflow: auto;
  }

  /* 让表格随行数增高，由外层容器滚动 */
  .panel-content--table-tall :deep(.el-table) {
    height: auto !important;
  }

  .panel-content--table-tall :deep(.el-table__body-wrapper) {
    max-height: none !important;
  }

  .issue-combined-bottom {
    display: grid;
    flex-shrink: 0;
    grid-template-columns: 1fr 1fr;
    gap: 6px;
    min-height: 260px;
    padding: 4px 8px 8px;
    border-top: 1px solid var(--board-border);
  }

  .issue-combined-chart {
    display: grid;
    flex: 1;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    min-height: 0;
    padding: 10px 12px 12px;
    overflow: hidden;
    border-top: 1px solid var(--board-border);
  }

  .issue-combined-chart__col {
    display: flex;
    flex-direction: column;
    min-height: 0;
    padding: 10px 12px;
    overflow: hidden;
    background: rgb(0 0 0 / 15%);
    border: 1px solid var(--board-border);
    border-radius: 8px;
  }

  .issue-combined-chart__title {
    flex-shrink: 0;
    margin-bottom: 8px;
    font-size: 13px;
    font-weight: 600;
    color: var(--board-text);
    letter-spacing: 0.02em;
  }

  .issue-combined-chart__wrap {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 180px;
    padding: 10px;
    overflow: hidden;
    background: rgb(0 0 0 / 20%);
    border-radius: 6px;
  }

  .issue-combined-chart__wrap > * {
    flex: 1;
    min-height: 0;
  }

  .issue-combined-table {
    display: flex;
    flex-direction: column;
    min-height: 0;
    overflow: hidden;
    background: rgb(255 255 255 / 3%);
    border: 1px solid var(--board-border);
    border-radius: 4px;
  }

  .issue-combined-table .panel-content {
    padding: 4px;
  }

  .issue-combined-table .panel-content--table-tall {
    flex: none;
  }

  .board-panel--producing {
    display: flex;
    flex-direction: column;
    min-height: 160px;
  }

  .panel-title--accent {
    color: var(--board-accent);
  }

  .producing-scroll-wrap {
    flex: 1;
    min-height: 0;
    overflow: hidden;
  }

  .producing-scroll-inner {
    animation: producing-scroll 40s linear infinite;
  }

  .producing-scroll-inner:hover {
    animation-play-state: paused;
  }

  @keyframes producing-scroll {
    0% {
      transform: translateY(0);
    }

    100% {
      transform: translateY(-50%);
    }
  }

  .producing-item {
    padding: 6px 8px;
    margin-bottom: 6px;
    font-size: 11px;
    background: rgb(255 255 255 / 4%);
    border: 1px solid var(--board-border);
    border-radius: 4px;
  }

  .producing-item__head {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 4px;
  }

  .producing-item__code {
    font-weight: 600;
    color: var(--board-accent);
  }

  .producing-item__type {
    font-size: 10px;
    color: var(--board-text-muted);
  }

  .producing-item__deliver {
    margin-left: auto;
    font-size: 10px;
    color: var(--board-text-muted);
  }

  .producing-item__client {
    margin-bottom: 6px;
    color: var(--board-text);
  }

  .producing-item__progress {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 4px;
  }

  .producing-item__progress-bar {
    flex: 1;
    height: 6px;
    overflow: hidden;
    background: rgb(255 255 255 / 10%);
    border-radius: 3px;
  }

  .producing-item__progress-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--board-accent), var(--board-success));
    border-radius: 3px;
    transition: width 0.2s;
  }

  .producing-item__progress-pct {
    min-width: 32px;
    font-variant-numeric: tabular-nums;
    color: var(--board-text-muted);
  }

  .producing-item__days {
    font-size: 10px;
    color: var(--board-text-muted);
  }

  .producing-item__remain {
    margin-left: 8px;
    color: var(--board-warn);
  }

  .text-success {
    color: var(--board-success);
  }

  .panel-content {
    flex: 1;
    min-height: 0;
    padding: 8px;
  }

  .panel-content--scroll {
    overflow: auto;
  }

  .board-bar-chart {
    --el-text-color-primary: var(--board-text);
    --el-text-color-regular: var(--board-text-muted);
    --el-color-primary: var(--board-accent);
  }

  .board-table {
    --el-table-bg-color: transparent !important;
    --el-table-tr-bg-color: transparent !important;
    --el-table-header-bg-color: rgb(255 255 255 / 8%) !important;
    --el-table-row-hover-bg-color: rgb(255 255 255 / 8%) !important;
    --el-table-border-color: var(--board-border) !important;
    --el-table-text-color: var(--board-text) !important;

    font-size: 12px;
  }

  .board-table :deep(.el-table) {
    background: transparent;
  }

  .board-table :deep(th.el-table__cell) {
    font-size: 12px;
    font-weight: 500;
    color: var(--board-text-muted);
  }

  .board-table :deep(td.el-table__cell) {
    color: var(--board-text);
  }

  .text-warn {
    color: var(--board-warn);
  }

  .text-danger {
    color: var(--board-danger);
  }

  @media (width <= 1200px) {
    .board-kpi {
      grid-template-columns: repeat(3, 1fr);
    }

    .board-issue {
      grid-template-columns: 1fr;
    }

    .issue-combined-bottom {
      grid-template-columns: 1fr;
      min-height: 220px;
    }

    .issue-combined-chart {
      min-height: 240px;
    }
  }

  @media (width <= 768px) {
    .contract-board {
      padding: 8px 10px;
    }

    .board-header {
      flex-wrap: wrap;
      gap: 8px;
      padding-bottom: 6px;
      margin-bottom: 6px;
    }

    .board-header-left {
      flex: 1 1 100%;
    }

    .board-title {
      font-size: 16px;
    }

    .board-subtitle {
      margin-top: 2px;
      font-size: 11px;
    }

    .board-header-right {
      gap: 8px;
      justify-content: flex-end;
      width: 100%;
    }

    .board-time {
      font-size: 12px;
    }

    .board-agro {
      flex-wrap: wrap;
      gap: 10px;
      padding: 6px 10px;
      margin-bottom: 6px;
    }

    .agro-item {
      min-width: calc(50% - 8px);
      font-size: 11px;
    }

    .board-kpi {
      grid-template-columns: repeat(2, 1fr);
      gap: 6px;
      margin-bottom: 6px;
    }

    .kpi-card {
      padding: 8px 6px;
    }

    .kpi-value {
      font-size: 18px;
    }

    .kpi-label {
      font-size: 10px;
    }

    .board-issue {
      margin-bottom: 6px;
    }

    .issue-combined-bottom {
      grid-template-columns: 1fr;
      min-height: 200px;
      padding: 4px 6px 6px;
    }

    .panel-content--issue-short {
      height: 180px;
      min-height: 180px;
      max-height: 180px;
    }

    .panel-content--table-tall {
      height: 160px;
      min-height: 160px;
    }

    .issue-combined-chart {
      grid-template-columns: 1fr;
      gap: 10px;
      padding: 8px 10px 10px;
    }

    .issue-combined-chart__col {
      padding: 8px 10px;
    }

    .issue-combined-chart__title {
      margin-bottom: 6px;
      font-size: 12px;
    }

    .issue-combined-chart__wrap {
      min-height: 140px;
    }
  }

  @media (width <= 480px) {
    .contract-board {
      padding: 6px 8px;
    }

    .board-header {
      gap: 6px;
    }

    .board-title {
      font-size: 15px;
    }

    .board-subtitle {
      display: -webkit-box;
      overflow: hidden;
      font-size: 10px;
      -webkit-line-clamp: 2;
      line-clamp: 2;
      -webkit-box-orient: vertical;
    }

    .board-agro .agro-item {
      min-width: 100%;
    }

    .board-kpi {
      gap: 4px;
    }

    .kpi-card {
      padding: 6px 4px;
    }

    .kpi-value {
      font-size: 16px;
    }

    .kpi-label {
      font-size: 10px;
    }

    .panel-title--compact {
      padding: 3px 6px;
      font-size: 11px;
    }

    .panel-content--issue-short {
      height: 160px;
      min-height: 160px;
      max-height: 160px;
      padding: 3px 6px;
    }

    .panel-content--table-tall {
      height: 140px;
      min-height: 140px;
    }

    .board-table :deep(th.el-table__cell),
    .board-table :deep(td.el-table__cell) {
      padding: 4px 6px;
      font-size: 11px;
    }

    .issue-combined-chart__wrap {
      min-height: 120px;
    }
  }
</style>
