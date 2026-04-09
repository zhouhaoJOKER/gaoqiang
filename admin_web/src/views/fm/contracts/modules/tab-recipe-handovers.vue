<template>
  <div class="tab-recipe-handovers">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="handleAdd"
        ><ArtSvgIcon icon="ri:add-line" class="mr-1" />新建配方交接单</ElButton
      >
    </div>
    <ElTable v-loading="loading" :data="list" border stripe>
      <ElTableColumn type="index" width="55" label="序号" />
      <ElTableColumn prop="code" label="配方单号" min-width="130">
        <template #default="{ row }">
          <ElButton link type="primary" @click="goDetail(row)">{{ row.code || '-' }}</ElButton>
        </template>
      </ElTableColumn>
      <ElTableColumn prop="name" label="产品名称" min-width="140" show-overflow-tooltip />
      <ElTableColumn prop="handover_date" label="交接日期" width="120" />
      <ElTableColumn prop="qty" label="数量" width="100">
        <template #default="{ row }">
          {{ row.qty ?? '-' }}
        </template>
      </ElTableColumn>
    </ElTable>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn } from 'element-plus'
  import { listRecipeHandoverContractApi } from '@/api/rms/recipe-handover'
  import { viewRecipeHandoverApi } from '@/api/rms/recipe-handover'

  const props = defineProps<{ contractId?: string | number }>()
  const emit = defineEmits<{ (e: 'add'): void }>()
  const router = useRouter()

  const loading = ref(false)
  const list = ref<any[]>([])

  const fetchList = async (contractId: string | number) => {
    if (!contractId) return
    loading.value = true
    try {
      const res = await listRecipeHandoverContractApi({
        'q[contract_id_eq]': contractId,
        per_page: 500
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      const rows = arr.map((rec: any) => {
        const h = rec.recipe_handover || {}
        return {
          id: rec.recipe_handover_id,
          code: h.code || rec.recipe_handover_code || '-',
          name: h.name || rec.recipe_handover_name || '-',
          handover_date: h.handover_date || rec.recipe_handover_date || '-',
          qty: rec.qty,
          _needFetch: !h.code && rec.recipe_handover_id
        }
      })
      const needFetch = rows.filter((r: any) => r._needFetch)
      if (needFetch.length > 0) {
        const details = await Promise.all(
          needFetch.map((r: any) =>
            viewRecipeHandoverApi({ id: r.id }).then((res: any) => ({
              id: r.id,
              data: (res as any).data || {}
            }))
          )
        )
        const map = Object.fromEntries(details.map((d: any) => [d.id, d.data]))
        list.value = rows.map((r: any) => {
          const rest = { ...r }
          delete rest._needFetch
          if (map[r.id]) {
            const d = map[r.id]
            return {
              ...rest,
              code: d.code || '-',
              name: d.name || '-',
              handover_date: d.handover_date || '-'
            }
          }
          return rest
        })
      } else {
        list.value = rows.map((r: any) => {
          const rest = { ...r }
          delete rest._needFetch
          return rest
        })
      }
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  const goDetail = (row: any) => {
    if (row.id) router.push({ path: `/rms/recipe-handovers/${row.id}` })
  }
  const handleAdd = () => emit('add')

  watch(
    () => props.contractId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-recipe-handovers .tab-toolbar {
    margin-bottom: 16px;
  }
</style>
