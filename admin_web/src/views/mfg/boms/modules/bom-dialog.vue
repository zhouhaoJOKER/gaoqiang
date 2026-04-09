<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1200px"
    :close-on-click-modal="false"
    class="bom-dialog-responsive"
    @closed="handleClosed"
  >
    <div class="bom-dialog-content">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px" label-position="top">
        <!-- 基本信息区域 -->
        <div class="form-section">
          <div class="section-title">基本信息</div>
          <ElRow :gutter="20">
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="BOM类型">
                <ElSelect
                  v-model="form.type_id"
                  placeholder="请选择类型"
                  style="width: 100%"
                  :disabled="props.readonly"
                  @change="handleTypeChange"
                >
                  <ElOption
                    v-for="item in bomTypeOptions"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                  <ElOption v-if="!props.readonly" value="__add_bom_type__" class="add-option">
                    <span
                      style="
                        display: flex;
                        gap: 4px;
                        align-items: center;
                        color: var(--el-color-primary);
                      "
                    >
                      <ArtSvgIcon icon="ri:add-line" />
                      新增类型
                    </span>
                  </ElOption>
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="BOM编号" prop="code">
                <ElInput v-model="form.code" placeholder="选择类型后自动生成" readonly />
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="产品" prop="product_id">
                <ElSelect
                  v-model="form.product_id"
                  placeholder="请选择产品"
                  filterable
                  remote
                  :remote-method="searchProducts"
                  :loading="productSearchLoading"
                  style="width: 100%"
                  :disabled="props.readonly"
                  @change="handleProductChange"
                >
                  <ElOption
                    v-for="product in productOptions"
                    :key="product.id"
                    :label="`[${product.code || ''}] ${product.name}`"
                    :value="product.id"
                  />
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="产品数量" prop="product_qty">
                <ElInput
                  v-model="form.product_qty"
                  type="number"
                  placeholder="1.00"
                  :readonly="props.readonly"
                />
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="计量单位">
                <ElSelect
                  v-model="form.uom_id"
                  placeholder="请选择单位"
                  style="width: 100%"
                  :disabled="props.readonly"
                  @change="handleUomChange"
                >
                  <ElOption
                    v-for="uom in uomOptions"
                    :key="uom.id"
                    :label="uom.name"
                    :value="uom.id"
                  />
                  <ElOption v-if="!props.readonly" value="__add_uom__" class="add-option">
                    <span
                      style="
                        display: flex;
                        gap: 4px;
                        align-items: center;
                        color: var(--el-color-primary);
                      "
                    >
                      <ArtSvgIcon icon="ri:add-line" />
                      新增单位
                    </span>
                  </ElOption>
                </ElSelect>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :sm="12" :md="8">
              <ElFormItem label="状态">
                <div class="switch-group">
                  <ElSwitch
                    v-model="form.is_active"
                    active-text="启用"
                    inactive-text="禁用"
                    :disabled="props.readonly"
                  />
                  <ElSwitch
                    v-model="form.is_default"
                    active-text="默认"
                    :disabled="props.readonly"
                    class="ml-4"
                  />
                </div>
              </ElFormItem>
            </ElCol>
          </ElRow>
        </div>

        <!-- 明细行区域 -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-title">BOM明细行</div>
            <ElButton v-if="!props.readonly" type="primary" size="small" @click="handleAddLine">
              <ArtSvgIcon icon="ri:add-line" />
              添加物料
            </ElButton>
          </div>
          <div class="table-wrapper">
            <ElTable :data="form.lines" border stripe style="width: 100%">
              <ElTableColumn type="index" label="序号" width="60" align="center" />
              <ElTableColumn label="物料产品" min-width="250">
                <template #default="{ row, $index }">
                  <ElSelect
                    v-model="row.product_id"
                    placeholder="搜索物料"
                    filterable
                    remote
                    :remote-method="(query) => searchLineProducts(query, $index)"
                    :loading="lineProductSearchLoading[$index]"
                    style="width: 100%"
                    :disabled="props.readonly"
                    @change="(val) => handleLineProductChange(val, $index)"
                  >
                    <ElOption
                      v-for="product in lineProductOptions[$index] || []"
                      :key="product.id"
                      :label="`[${product.code || ''}] ${product.name}`"
                      :value="product.id"
                    />
                  </ElSelect>
                </template>
              </ElTableColumn>
              <ElTableColumn label="数量" width="150">
                <template #default="{ row }">
                  <ElInput
                    v-model="row.product_qty"
                    type="number"
                    placeholder="0.00"
                    :readonly="props.readonly"
                  />
                </template>
              </ElTableColumn>
              <ElTableColumn label="计量单位" width="120">
                <template #default="{ row }">
                  <ElSelect
                    v-model="row.product_uom_id"
                    placeholder="单位"
                    style="width: 100%"
                    :disabled="props.readonly"
                  >
                    <ElOption
                      v-for="uom in uomOptions"
                      :key="uom.id"
                      :label="uom.name"
                      :value="uom.id"
                    />
                  </ElSelect>
                </template>
              </ElTableColumn>
              <ElTableColumn label="工序" min-width="150">
                <template #default="{ row }">
                  <ElInput
                    v-model="row.operation_id"
                    placeholder="可选工序"
                    :readonly="props.readonly"
                  />
                </template>
              </ElTableColumn>
              <ElTableColumn label="可选" width="80" align="center">
                <template #default="{ row }">
                  <ElCheckbox v-model="row.optional" :disabled="props.readonly" />
                </template>
              </ElTableColumn>
              <ElTableColumn
                v-if="!props.readonly"
                label="操作"
                width="80"
                align="center"
                fixed="right"
              >
                <template #default="{ $index }">
                  <ElButton type="danger" size="small" text @click="handleRemoveLine($index)">
                    <ArtSvgIcon icon="ri:delete-bin-line" />
                  </ElButton>
                </template>
              </ElTableColumn>
            </ElTable>
          </div>
        </div>

        <!-- 副产品区域 -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-title">副产品/废料</div>
            <ElButton
              v-if="!props.readonly"
              type="primary"
              size="small"
              @click="handleAddByproduct"
            >
              <ArtSvgIcon icon="ri:add-line" />
              添加副产品
            </ElButton>
          </div>
          <div class="table-wrapper">
            <ElTable :data="form.byproducts" border stripe style="width: 100%">
              <ElTableColumn type="index" label="序号" width="60" align="center" />
              <ElTableColumn label="产品" min-width="250">
                <template #default="{ row, $index }">
                  <ElSelect
                    v-model="row.product_id"
                    placeholder="搜索产品"
                    filterable
                    remote
                    :remote-method="(query) => searchByproductProducts(query, $index)"
                    :loading="byproductProductSearchLoading[$index]"
                    style="width: 100%"
                    :disabled="props.readonly"
                    @change="(val) => handleByproductProductChange(val, $index)"
                  >
                    <ElOption
                      v-for="product in byproductProductOptions[$index] || []"
                      :key="product.id"
                      :label="`[${product.code || ''}] ${product.name}`"
                      :value="product.id"
                    />
                  </ElSelect>
                </template>
              </ElTableColumn>
              <ElTableColumn label="数量" width="150">
                <template #default="{ row }">
                  <ElInput
                    v-model="row.product_qty"
                    type="number"
                    placeholder="0.00"
                    :readonly="props.readonly"
                  />
                </template>
              </ElTableColumn>
              <ElTableColumn label="计量单位" width="120">
                <template #default="{ row }">
                  <ElSelect
                    v-model="row.product_uom_id"
                    placeholder="单位"
                    style="width: 100%"
                    :disabled="props.readonly"
                  >
                    <ElOption
                      v-for="uom in uomOptions"
                      :key="uom.id"
                      :label="uom.name"
                      :value="uom.id"
                    />
                  </ElSelect>
                </template>
              </ElTableColumn>
              <ElTableColumn label="输出类别" width="150">
                <template #default="{ row }">
                  <ElSelect
                    v-model="row.output_category"
                    style="width: 100%"
                    :disabled="props.readonly"
                  >
                    <ElOption label="废料" value="scrap" />
                    <ElOption label="副产品" value="byproduct" />
                  </ElSelect>
                </template>
              </ElTableColumn>
              <ElTableColumn label="是否库存" width="100" align="center">
                <template #default="{ row }">
                  <ElCheckbox v-model="row.is_inventory" :disabled="props.readonly" />
                </template>
              </ElTableColumn>
              <ElTableColumn
                v-if="!props.readonly"
                label="操作"
                width="80"
                align="center"
                fixed="right"
              >
                <template #default="{ $index }">
                  <ElButton type="danger" size="small" text @click="handleRemoveByproduct($index)">
                    <ArtSvgIcon icon="ri:delete-bin-line" />
                  </ElButton>
                </template>
              </ElTableColumn>
            </ElTable>
          </div>
        </div>
      </ElForm>
    </div>

    <!-- 属性配置对话框 (用于BOM类型和计量单位) -->
    <PropertyConfigDialog
      v-model="propertyConfigVisible"
      :sign="currentPropertySign"
      :title="currentPropertyTitle"
      @updated="handlePropertyUpdated"
    />

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '取消' }}</ElButton>
        <template v-if="!props.readonly">
          <ElButton type="primary" @click="handleSave">保存</ElButton>
        </template>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import {
    ElDialog,
    ElForm,
    ElFormItem,
    ElInput,
    ElSelect,
    ElOption,
    ElButton,
    ElRow,
    ElCol,
    ElSwitch,
    ElTable,
    ElTableColumn,
    ElCheckbox
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import {
    createMfgBomApi,
    updateMfgBomApi,
    viewMfgBomApi,
    listMfgBomLineApi,
    listMfgBomByproductApi
  } from '@/api/mfg/bom'
  import { listMatProductApi, viewMatProductApi } from '@/api/mat/product'
  import { listPropertyApi } from '@/api/property'

  interface Props {
    modelValue: boolean
    bom?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', bom: any): void
    (e: 'updated', bom: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    bom: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.bom && !!props.bom.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看BOM'
    return isEditMode.value ? '编辑BOM' : '创建BOM'
  })

  const formRef = ref<FormInstance>()
  const propertyConfigVisible = ref(false)
  const currentPropertySign = ref('')
  const currentPropertyTitle = ref('')
  const bomTypeOptions = ref<any[]>([])

  const rules = reactive<FormRules>({
    code: [{ required: true, message: 'BOM编号自动生成', trigger: 'blur' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    product_qty: [{ required: true, message: '请输入产品数量', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined,
    code: '',
    product_id: undefined as string | number | undefined,
    type_id: undefined as string | number | undefined,
    product_qty: 1,
    uom_id: undefined as string | number | undefined,
    is_active: true,
    is_default: false,
    ready_to_produce: 0,
    picking_type_id: undefined as string | number | undefined,
    company_id: undefined as string | number | undefined,
    lines: [] as any[],
    byproducts: [] as any[]
  })

  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const uomOptions = ref<any[]>([])
  const lineProductOptions = ref<Record<number, any[]>>({})
  const lineProductSearchLoading = ref<Record<number, boolean>>({})
  const byproductProductOptions = ref<Record<number, any[]>>({})
  const byproductProductSearchLoading = ref<Record<number, boolean>>({})

  // 加载BOM类型选项
  const loadBomTypeOptions = async () => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'bom_type', per_page: 100 })
      const data = (res as any).data || []
      const list = Array.isArray(data) ? data : []
      bomTypeOptions.value = list.filter(
        (item: any) => item && item.id != null && item.id !== '' && item.name
      )
    } catch (error) {
      console.error('加载BOM类型失败:', error)
      bomTypeOptions.value = []
    }
  }

  // 监听选择框变化，处理“新增”选项
  watch(
    () => form.type_id,
    (val) => {
      if (val === '__add_bom_type__') {
        form.type_id = undefined
        currentPropertySign.value = 'bom_type'
        currentPropertyTitle.value = '配置BOM类型'
        propertyConfigVisible.value = true
      }
    }
  )

  watch(
    () => form.uom_id,
    (val) => {
      if (val === '__add_uom__') {
        form.uom_id = undefined
        currentPropertySign.value = 'product_uom'
        currentPropertyTitle.value = '配置计量单位'
        propertyConfigVisible.value = true
      }
    }
  )

  const handlePropertyUpdated = async () => {
    if (currentPropertySign.value === 'bom_type') {
      await loadBomTypeOptions()
    } else if (currentPropertySign.value === 'product_uom') {
      await loadUomOptions()
    }
  }

  // 计量单位变更处理 (同步到明细和副产品)
  const handleUomChange = (val: any) => {
    if (val && val !== '__add_uom__') {
      // 同步明细行单位
      form.lines.forEach((line) => {
        line.product_uom_id = val
      })
      // 同步副产品单位
      form.byproducts.forEach((item) => {
        item.product_uom_id = val
      })
    }
  }

  // 加载计量单位
  const loadUomOptions = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'product_uom',
        per_page: 100
      })
      const data = (res as any).data || []
      const list = Array.isArray(data) ? data : []
      uomOptions.value = list.filter(
        (item: any) => item && item.id != null && item.id !== '' && item.name
      )
    } catch (error) {
      console.error('加载计量单位失败:', error)
      uomOptions.value = []
    }
  }

  // 搜索产品
  const searchProducts = async (query: string): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      const data = (res as any).data || []
      productOptions.value = Array.isArray(data)
        ? data.filter((item: any) => item && item.id != null)
        : []
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  // 产品变更处理 (自动带入单位)
  const handleProductChange = async (val: any) => {
    if (!val) {
      form.uom_id = undefined
      return
    }
    try {
      const res = await viewMatProductApi({ id: val })
      const product = (res as any).data
      if (product && product.uom_id) {
        form.uom_id = product.uom_id
        // 自动同步单位到现有的明细和副产品
        handleUomChange(product.uom_id)
      }
    } catch (error) {
      console.error('获取产品详情失败:', error)
    }
  }

  // 搜索明细产品
  const searchLineProducts = async (query: string, index: number): Promise<void> => {
    lineProductSearchLoading.value[index] = true
    try {
      const res = await listMatProductApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      const data = (res as any).data || []
      lineProductOptions.value[index] = Array.isArray(data)
        ? data.filter((item: any) => item && item.id != null)
        : []
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      lineProductSearchLoading.value[index] = false
    }
  }

  // 明细产品变更 (自动带入单位)
  const handleLineProductChange = async (val: any, index: number) => {
    if (!val) {
      form.lines[index].product_uom_id = undefined
      return
    }
    try {
      const res = await viewMatProductApi({ id: val })
      const product = (res as any).data
      if (product && product.uom_id) {
        form.lines[index].product_uom_id = product.uom_id
      }
    } catch (error) {
      console.error('获取物料详情失败:', error)
    }
  }

  // 搜索副产品
  const searchByproductProducts = async (query: string, index: number): Promise<void> => {
    byproductProductSearchLoading.value[index] = true
    try {
      const res = await listMatProductApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      const data = (res as any).data || []
      byproductProductOptions.value[index] = Array.isArray(data)
        ? data.filter((item: any) => item && item.id != null)
        : []
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      byproductProductSearchLoading.value[index] = false
    }
  }

  // 副产品变更 (自动带入单位)
  const handleByproductProductChange = async (val: any, index: number) => {
    if (!val) {
      form.byproducts[index].product_uom_id = undefined
      return
    }
    try {
      const res = await viewMatProductApi({ id: val })
      const product = (res as any).data
      if (product && product.uom_id) {
        form.byproducts[index].product_uom_id = product.uom_id
      }
    } catch (error) {
      console.error('获取副产品详情失败:', error)
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      product_id: undefined,
      product_qty: 1,
      product_uom_id: form.uom_id, // 默认带入BOM主单位
      operation_id: undefined,
      optional: false
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
    delete lineProductOptions.value[index]
  }

  const handleAddByproduct = () => {
    form.byproducts.push({
      product_id: undefined,
      product_qty: 1,
      product_uom_id: form.uom_id, // 默认带入BOM主单位
      output_category: 'byproduct',
      is_inventory: false
    })
  }

  const handleRemoveByproduct = (index: number) => {
    form.byproducts.splice(index, 1)
    delete byproductProductOptions.value[index]
  }

  const loadBomDetail = async (): Promise<void> => {
    if (!props.bom?.id) return
    try {
      const res = await viewMfgBomApi({ id: props.bom.id })
      const bomData = (res as any).data || {}
      Object.assign(form, {
        id: bomData.id,
        code: bomData.code || '',
        product_id: bomData.product_id,
        type_id: bomData.type_id,
        product_qty: bomData.product_qty || 1,
        uom_id: bomData.uom_id,
        is_active: bomData.is_active !== false,
        is_default: bomData.is_default || false,
        ready_to_produce: bomData.ready_to_produce || 0,
        picking_type_id: bomData.picking_type_id,
        company_id: bomData.company_id,
        lines: [],
        byproducts: []
      })

      // 确保选项列表中包含当前详情的 type_id 和 uom_id (防止只显示ID)
      if (bomData.type_id && bomData.type) {
        const exists = bomTypeOptions.value.some((opt) => opt.id === bomData.type_id)
        if (!exists) {
          bomTypeOptions.value.push({
            id: bomData.type_id,
            name: bomData.type.name,
            abbr: bomData.type.abbr
          })
        }
      }

      if (bomData.uom_id && bomData.uom) {
        const exists = uomOptions.value.some((opt) => opt.id === bomData.uom_id)
        if (!exists) {
          uomOptions.value.push({
            id: bomData.uom_id,
            name: bomData.uom.name
          })
        }
      }

      // 加载明细行
      const linesRes = await listMfgBomLineApi({
        'q[bom_id_eq]': props.bom.id
      })
      const lines = (linesRes as any).data || []
      form.lines = lines.map((line: any, index: number) => {
        searchLineProducts('', index)
        return {
          id: line.id,
          product_id: line.product_id,
          product_qty: line.product_qty || 0,
          product_uom_id: line.product_uom_id,
          operation_id: line.operation_id,
          optional: line.optional || false
        }
      })

      // 加载副产品
      const byproductsRes = await listMfgBomByproductApi({
        'q[bom_id_eq]': props.bom.id
      })
      const byproducts = (byproductsRes as any).data || []
      form.byproducts = byproducts.map((byproduct: any, index: number) => {
        searchByproductProducts('', index)
        return {
          id: byproduct.id,
          product_id: byproduct.product_id,
          product_qty: byproduct.product_qty || 0,
          product_uom_id: byproduct.product_uom_id,
          output_category: byproduct.output_category || 'byproduct',
          is_inventory: byproduct.is_inventory || false
        }
      })

      if (form.product_id) {
        await searchProducts('')
      }
    } catch (error) {
      console.error('加载BOM详情失败:', error)
      ElMessage.error('加载BOM详情失败')
    }
  }

  const handleSave = async (): Promise<void> => {
    if (props.readonly) {
      handleCancel()
      return
    }
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params = {
        code: form.code,
        product_id: form.product_id,
        type_id: form.type_id,
        product_qty: Number(form.product_qty) || 0,
        uom_id: form.uom_id,
        is_active: form.is_active,
        is_default: form.is_default,
        ready_to_produce: Number(form.ready_to_produce) || 0,
        picking_type_id: form.picking_type_id,
        company_id: form.company_id,
        lines: form.lines.map((line) => ({
          product_id: line.product_id,
          product_qty: Number(line.product_qty) || 0,
          product_uom_id: line.product_uom_id,
          operation_id: line.operation_id,
          optional: line.optional || false
        })),
        byproducts: form.byproducts.map((byproduct) => ({
          product_id: byproduct.product_id,
          product_qty: Number(byproduct.product_qty) || 0,
          product_uom_id: byproduct.product_uom_id,
          output_category: byproduct.output_category || 'byproduct',
          is_inventory: byproduct.is_inventory || false
        }))
      }

      if (isEditMode.value) {
        const res = await updateMfgBomApi(String(props.bom.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.bom, ...params })
      } else {
        const res = await createMfgBomApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      handleCancel()
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      code: '',
      product_id: undefined,
      type_id: undefined,
      product_qty: 1,
      uom_id: undefined,
      is_active: true,
      is_default: false,
      ready_to_produce: 0,
      picking_type_id: undefined,
      company_id: undefined,
      lines: [],
      byproducts: []
    })
    lineProductOptions.value = {}
    byproductProductOptions.value = {}
    formRef.value?.resetFields()
  }

  const handleTypeChange = (val: any) => {
    if (val && val !== '__add_bom_type__') {
      generateBomCode()
    } else {
      form.code = ''
    }
  }

  // 自动生成BOM编号
  const generateBomCode = () => {
    if (isEditMode.value) return
    const selectedType = bomTypeOptions.value.find((item) => item.id === form.type_id)
    const abbr = selectedType?.abbr || 'XX'

    const now = new Date()
    const year = String(now.getFullYear()).slice(-2)
    const month = String(now.getMonth() + 1).padStart(2, '0')
    const day = String(now.getDate()).padStart(2, '0')
    const dateStr = `${year}${month}${day}`

    // 随机生成最后两位，模拟序号 (实际生产建议由后端生成唯一序列)
    const random = String(Math.floor(Math.random() * 99) + 1).padStart(2, '0')

    form.code = `BOM-${abbr}-${dateStr}${random}`
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchProducts('')
        await loadUomOptions()
        await loadBomTypeOptions()
        if (isEditMode.value) {
          await loadBomDetail()
        } else {
          form.lines = []
          form.byproducts = []
        }
      }
    }
  )

  watch(
    () => props.bom,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadBomDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .bom-dialog-content {
    max-height: 70vh;
    padding: 0 10px;
    overflow-y: auto;

    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-thumb {
      background: var(--el-border-color-lighter);
      border-radius: 3px;
    }

    .form-section {
      padding: 20px;
      margin-bottom: 24px;
      background: var(--el-bg-color-overlay);
      border: 1px solid var(--el-border-color-light);
      border-radius: 8px;
      box-shadow: 0 2px 12px 0 rgb(0 0 0 / 5%);

      .section-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
      }

      .section-title {
        position: relative;
        padding-left: 12px;
        margin-bottom: 16px;
        font-size: 16px;
        font-weight: 600;
        color: var(--el-text-color-primary);

        &::before {
          position: absolute;
          top: 50%;
          left: 0;
          width: 4px;
          height: 16px;
          content: '';
          background: var(--el-color-primary);
          border-radius: 2px;
          transform: translateY(-50%);
        }
      }

      .section-header .section-title {
        margin-bottom: 0;
      }
    }

    .type-selector-wrapper {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .switch-group {
      display: flex;
      align-items: center;
      height: 32px;
    }

    .table-wrapper {
      overflow: hidden;
      border-radius: 4px;
    }

    .ml-4 {
      margin-left: 16px;
    }
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding: 10px 0;
  }
</style>

<style lang="scss">
  .bom-dialog-responsive {
    .el-dialog__body {
      padding: 10px 24px 20px;
    }

    .el-form-item__label {
      padding-bottom: 4px !important;
      font-weight: 500;
    }
  }
</style>
