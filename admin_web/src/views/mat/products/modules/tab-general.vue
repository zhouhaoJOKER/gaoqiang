<!-- eslint-disable vue/no-mutating-props -- 父组件传入共享的 productData，子组件直接编辑以保持双向同步 -->
<template>
  <div class="general-tab">
    <div class="fields-grid">
      <div class="fields-column">
        <div class="section-block">
          <div class="section-title">基本信息</div>
          <div class="field-row">
            <div class="field-label">名称</div>
            <div class="field-value">
              <ElInput
                v-model="productData.name"
                placeholder="请输入产品名称"
                @blur="() => saveProductField('name', productData.name)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">编码</div>
            <div class="field-value">
              <ElInput
                v-model="productData.code"
                placeholder="请输入产品编码"
                @blur="() => saveProductField('code', productData.code)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">类型</div>
            <div class="field-value">
              <ElRadioGroup v-model="productData.type_id" @change="handleTypeChange">
                <ElRadio :label="0">服务</ElRadio>
                <ElRadio :label="1">实物</ElRadio>
                <ElRadio :label="2">结合</ElRadio>
              </ElRadioGroup>
            </div>
          </div>
          <div v-if="productData.type_id === 2" class="field-row">
            <div class="field-label">组合选择</div>
            <div class="field-value">
              <ElSelect
                v-model="productData.combo_id"
                placeholder="选择一种产品"
                filterable
                remote
                :remote-method="searchCombos"
                :loading="comboSearchLoading"
                style="width: 100%"
                @change="handleComboChange"
              >
                <ElOption
                  v-for="combo in comboOptions"
                  :key="combo.id"
                  :label="combo.name"
                  :value="combo.id"
                />
                <ElOption
                  :value="''"
                  disabled
                  style="border-top: 1px solid var(--el-border-color-lighter)"
                >
                  <div class="combo-option-footer">
                    <ElButton text type="primary" size="small" @click.stop="handleCreateCombo">
                      创建...
                    </ElButton>
                  </div>
                </ElOption>
              </ElSelect>
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">产品大类</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.parent_category_id"
                sign="product_category"
                placeholder="请选择产品大类"
                :root-only="true"
                @change="onParentCategoryChange"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">规格</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.category_id"
                sign="product_category"
                placeholder="请先选择大类，再选规格"
                :parent-id-eq="productData.parent_category_id"
                :disabled="!productData.parent_category_id"
                @change="(val) => saveProductField('category_id', val)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">描述</div>
            <div class="field-value">
              <ElInput
                v-model="productData.description"
                type="textarea"
                :rows="4"
                placeholder="请输入产品描述"
                @blur="() => saveProductField('description', productData.description)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">产品材质</div>
            <div class="field-value">
              <ElInput
                v-model="productData.material"
                placeholder="例如：PE/COEX"
                @blur="() => saveProductField('material', productData.material)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">满口容量</div>
            <div class="field-value">
              <ElInput
                v-model="productData.full_capacity"
                placeholder="例如：1150ml"
                @blur="() => saveProductField('full_capacity', productData.full_capacity)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">公称容量</div>
            <div class="field-value">
              <ElInput
                v-model="productData.nominal_capacity"
                placeholder="例如：1000ml"
                @blur="() => saveProductField('nominal_capacity', productData.nominal_capacity)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">克重</div>
            <div class="field-value">
              <ElInput
                v-model="productData.gram_weight"
                placeholder="例如：45g"
                @blur="() => saveProductField('gram_weight', productData.gram_weight)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">口径</div>
            <div class="field-value">
              <ElInput
                v-model="productData.caliber"
                placeholder="例如：45mm"
                @blur="() => saveProductField('caliber', productData.caliber)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">带盖高度</div>
            <div class="field-value">
              <ElInput
                v-model="productData.cap_height"
                placeholder="例如：220mm"
                @blur="() => saveProductField('cap_height', productData.cap_height)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">最大直径</div>
            <div class="field-value">
              <ElInput
                v-model="productData.max_diameter"
                placeholder="例如：92mm"
                @blur="() => saveProductField('max_diameter', productData.max_diameter)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">贴标尺寸</div>
            <div class="field-value">
              <ElInput
                v-model="productData.label_size"
                placeholder="例如：137mm*285mm"
                @blur="() => saveProductField('label_size', productData.label_size)"
              />
            </div>
          </div>
        </div>

        <div class="section-block">
          <div class="section-title">价格信息</div>
          <div class="field-row">
            <div class="field-label">售价</div>
            <div class="field-value">
              <ElInput
                v-model="productData.price"
                type="number"
                placeholder="0.00"
                @blur="() => handleNumberBlur('price')"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">成本价</div>
            <div class="field-value">
              <ElInput
                v-model="productData.cost_price"
                type="number"
                placeholder="0.00"
                @blur="() => handleNumberBlur('cost_price')"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">市场价</div>
            <div class="field-value">
              <ElInput
                v-model="productData.market_price"
                type="number"
                placeholder="0.00"
                @blur="() => handleNumberBlur('market_price')"
              />
            </div>
          </div>
        </div>
      </div>

      <div class="fields-column">
        <div class="section-block">
          <div class="section-title">单位与税率</div>
          <div class="field-row">
            <div class="field-label">计量单位</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.uom_id"
                sign="product_uom"
                placeholder="请选择计量单位"
                @change="(val) => saveProductField('uom_id', val)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">采购单位</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.uom_po_id"
                sign="product_uom"
                placeholder="请选择采购单位"
                @change="(val) => saveProductField('uom_po_id', val)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">销售税</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.sale_tax_id"
                sign="product_sale_tax"
                placeholder="请选择销售税"
                @change="(val) => saveProductField('sale_tax_id', val)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">采购税</div>
            <div class="field-value">
              <PropertySelectWithAdd
                v-model="productData.purchase_tax_id"
                sign="product_sale_tax"
                placeholder="请选择采购税"
                @change="(val) => saveProductField('purchase_tax_id', val)"
              />
            </div>
          </div>
        </div>

        <!-- 拓展信息区域 -->
        <div class="section-block">
          <div class="section-title">拓展信息</div>
          <div class="field-row">
            <div class="field-label">公司</div>
            <div class="field-value">
              <ElTreeSelect
                v-model="productData.company_id"
                :data="companyTreeData"
                :props="treeSelectProps"
                :expand-on-click-node="true"
                :only-show-leaf-nodes="false"
                placeholder="请选择公司"
                check-strictly
                filterable
                clearable
                style="width: 100%"
                @change="(val: any) => saveProductField('company_id', val)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">标签</div>
            <div class="field-value">
              <TagSelector
                :model-value="normalizedLabels"
                sign="product_label"
                placeholder="添加标签"
                @update:model-value="handleLabelsChange"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">拼音简写</div>
            <div class="field-value">
              <ElInput
                v-model="productData.py"
                placeholder="拼音简写"
                readonly
                style="background-color: var(--el-fill-color-lighter)"
              />
            </div>
          </div>
          <div class="field-row">
            <div class="field-label">拼音全拼</div>
            <div class="field-value">
              <ElInput
                v-model="productData.pinyin"
                placeholder="拼音全拼"
                readonly
                style="background-color: var(--el-fill-color-lighter)"
              />
            </div>
          </div>
        </div>

        <div class="general-aside">
          <ElCard class="meta-card" shadow="never">
            <div class="meta-grid">
              <div class="meta-row">
                <span class="meta-label">创建人</span>
                <span class="meta-value">{{ productData.user_name || '-' }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label">创建时间</span>
                <span class="meta-value">{{ productData.created_time || '-' }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label">更新人</span>
                <span class="meta-value">{{ productData.updater_name || '-' }}</span>
              </div>
              <div class="meta-row">
                <span class="meta-label">更新时间</span>
                <span class="meta-value">{{ productData.updated_time || '-' }}</span>
              </div>
            </div>
          </ElCard>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { nextTick } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { ref, computed, onMounted } from 'vue'
  import {
    ElInput,
    ElCard,
    ElRadioGroup,
    ElRadio,
    ElSelect,
    ElOption,
    ElButton,
    ElTreeSelect
  } from 'element-plus'
  import { listMatAttributeLineApi } from '@/api/mat/attribute'
  import { listCompanyApi } from '@/api/company'
  import TagSelector from '@/components/TagSelector.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    productData: any
    comboOptions: any[]
    comboSearchLoading: boolean
  }

  interface Emits {
    (e: 'save-field', field: string, value: any): void
    (e: 'number-blur', field: string): void
    (e: 'combo-change', comboId: string | number): void
    (e: 'search-combos', query: string): void
    (e: 'create-combo'): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const saveProductField = (field: string, value: any): void => {
    emit('save-field', field, value)
  }

  /** 切换大类时仅更新本地，需重新选规格后再保存 category_id */
  const onParentCategoryChange = (val: string | number | null): void => {
    // eslint-disable-next-line vue/no-mutating-props
    props.productData.parent_category_id = val
    // eslint-disable-next-line vue/no-mutating-props
    props.productData.category_id = undefined
  }

  const handleNumberBlur = (field: string): void => {
    emit('number-blur', field)
  }

  const handleComboChange = (comboId: string | number): void => {
    emit('combo-change', comboId)
  }

  const searchCombos = (query: string): void => {
    emit('search-combos', query)
  }

  const handleCreateCombo = (): void => {
    emit('create-combo')
  }

  // 公司树形数据
  const companyTreeData = ref<any[]>([])
  const loadingCompanies = ref(false)

  // 树选择器配置
  const treeSelectProps = {
    label: 'name',
    children: 'children',
    value: 'id'
  }

  // 标签相关 - 规范化标签数据格式
  const normalizedLabels = computed(() => {
    if (!props.productData.labels || !Array.isArray(props.productData.labels)) {
      return []
    }
    // 如果已经是对象数组，直接返回
    if (props.productData.labels.length > 0 && typeof props.productData.labels[0] === 'object') {
      return props.productData.labels
    }
    // 如果是ID数组，返回空数组（TagSelector 会从 tagList 中查找）
    return []
  })

  // 处理标签变化
  const handleLabelsChange = (tags: any[]): void => {
    // TagSelector 返回的是对象数组，保存为包含 id, name, color 的 hash 数组
    const labelHashArray = tags.map((tag) => ({
      id: tag.id,
      name: tag.name,
      color: tag.color || ''
    }))
    saveProductField('labels', labelHashArray)
  }

  // 加载公司树形数据
  const loadCompanyTreeData = async (): Promise<void> => {
    loadingCompanies.value = true
    try {
      const response = await listCompanyApi({})
      const companies = (response as any).data || []
      companyTreeData.value = buildCompanyTree(companies)
    } catch (error) {
      console.error('获取公司列表失败:', error)
    } finally {
      loadingCompanies.value = false
    }
  }

  // 构建公司树形结构
  const buildCompanyTree = (items: any[]): any[] => {
    const map: any = {}
    const tree: any[] = []

    items.forEach((item) => {
      map[item.id] = { ...item, children: [] }
    })

    items.forEach((item) => {
      if (item.parent_id && map[item.parent_id]) {
        map[item.parent_id].children.push(map[item.id])
      } else {
        tree.push(map[item.id])
      }
    })

    return tree
  }

  // 标签相关功能已移至 TagSelector 组件

  onMounted(() => {
    loadCompanyTreeData()
  })

  // 处理产品类型改变
  const handleTypeChange = async (val: number | string | boolean | undefined): Promise<void> => {
    if (val === undefined) return
    const newTypeId = Number(val)
    const oldTypeId = props.productData.type_id

    // 如果改为组合类型（type_id=2），检查是否有变体属性，且不立即持久化 type_id
    if (newTypeId === 2 && oldTypeId !== 2) {
      if (!props.productData.id) {
        // 新建产品：仅更新 UI，不持久化；等选择组合后再一并保存
        return
      }

      try {
        // 检查是否有变体属性
        const res = await listMatAttributeLineApi({
          'q[product_id_eq]': props.productData.id,
          'q[is_variant_eq]': true
        })
        const data = (res as any).data || {}
        const variantAttributes = Array.isArray(data)
          ? data
          : data.list || data.data || data.records || []

        if (variantAttributes.length > 0) {
          // 有变体属性，不允许改为组合类型
          await ElMessageBox.confirm(
            `该产品已有 ${variantAttributes.length} 个变体属性。组合类型产品不支持变体创建，无法更改产品类型。请先删除或修改变体属性。`,
            '无法更改产品类型',
            {
              type: 'warning',
              confirmButtonText: '确定'
            }
          )
          await nextTick()
          // 回滚 type_id 到原值
          // eslint-disable-next-line vue/no-mutating-props
          props.productData.type_id = oldTypeId
          return
        }
      } catch (error: any) {
        if (error !== 'cancel') {
          console.error('检查变体属性失败:', error)
          ElMessage.error('检查失败，无法更改产品类型')
          await nextTick()
          // eslint-disable-next-line vue/no-mutating-props
          props.productData.type_id = oldTypeId
          return
        }
        await nextTick()
        // eslint-disable-next-line vue/no-mutating-props
        props.productData.type_id = oldTypeId
        return
      }
      // 通过校验：仅更新 UI 显示组合选择，不持久化 type_id；等用户选择组合后再保存
      return
    }

    // 改为非组合类型：直接持久化
    saveProductField('type_id', newTypeId)
  }
</script>

<style scoped lang="scss">
  .general-tab {
    .fields-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 24px;
    }

    .fields-column {
      display: flex;
      flex-direction: column;
    }

    .section-block {
      padding-bottom: 20px;
      margin-bottom: 20px;
      border-bottom: 1px solid var(--el-border-color-lighter);

      &:last-child {
        border-bottom: none;
      }
    }

    .section-title {
      margin-bottom: 16px;
      font-size: 15px;
      font-weight: 500;
      color: var(--el-text-color-primary);
    }

    .field-row {
      display: flex;
      gap: 16px;
      align-items: center;
      margin-bottom: 14px;

      .field-label {
        flex-shrink: 0;
        width: 90px;
        font-size: 13px;
        color: var(--el-text-color-regular);
      }

      .field-value {
        flex: 1;
      }
    }

    .general-aside {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .image-card {
      .image-wrapper {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 200px;
        background: var(--el-fill-color-light);
        border-radius: 8px;
      }

      .product-image {
        width: 100%;
        height: 100%;
      }
    }

    .image-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      font-size: 32px;
      color: var(--el-text-color-placeholder);
    }

    .meta-card {
      .meta-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 12px;

        .meta-row {
          display: flex;
          flex-direction: column;
          gap: 4px;
          padding: 8px 0;
          font-size: 13px;
          color: var(--el-text-color-regular);

          .meta-label {
            font-size: 12px;
            color: var(--el-text-color-secondary);
          }

          .meta-value {
            font-weight: 500;
            color: var(--el-text-color-primary);
          }
        }
      }

      @media (width <= 768px) {
        .meta-grid {
          grid-template-columns: 1fr;
        }
      }
    }

    .category-select-wrapper {
      width: 100%;
    }

    .category-option-footer {
      display: flex;
      gap: 8px;
      justify-content: center;
      padding: 8px 0;
    }

    .combo-option-footer {
      display: flex;
      gap: 8px;
      justify-content: center;
      padding: 8px 0;
    }
  }

  @media (width <= 1200px) {
    .general-tab {
      .fields-grid {
        grid-template-columns: 1fr;
      }
    }
  }
</style>
